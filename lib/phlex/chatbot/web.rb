# frozen_string_literal: true

require_relative "client/web_socket"
require_relative "client/server_sent_events"

module Phlex
  module Chatbot
    # Rack app to serve the chatbot assets

    class Web
      def self.call(env)
        new(env).call
      end

      def initialize(env)
        @env = env
      end

      def call
        case request_method
        when "GET" then on_get
        when "POST" then on_post
        else raise "Unsupported request method: #{request_method}"
        end
      end

      private

      def css
        File.read(File.join(ROOT_DIR, "dist", "bot.css"))
      end

      def js
        File.read(File.join(ROOT_DIR, "dist", "bot.js"))
      end

      def js_map
        File.read(File.join(ROOT_DIR, "dist", "bot.js.map"))
      end

      def on_get # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
        case path
        when "/bot.css"
          [200, { "content-type" => "text/css" }, [css]]
        when "/bot.js"
          [200, { "content-type" => "application/javascript" }, [js]]
        when "/bot.js.map"
          [200, { "content-type" => "application/javascript" }, [js_map]]
        when %r{/join/([a-fA-F0-9]+$)}
          channel = Switchboard.find(Regexp.last_match(1))
          return respond_not_found! unless channel

          if @env["HTTP_UPGRADE"]&.starts_with?("websocket")
            return respond_not_found! unless valid_origin?

            channel.subscribe(Client::WebSocket.new(@env, channel.channel_id))
            [-1, {}, []]
          elsif @env["HTTP_ACCEPT"]&.include?("text/event-stream")
            [200, sse_headers, ->(io) { channel.subscribe(Client::ServerSentEvents.new(io, @env)) }]
          else
            respond_not_found!
          end
        else
          respond_not_found!
        end
      end

      def on_post
        case path
        when %r{/ask/([a-fA-F0-9]+$)}
          return respond_not_found! unless valid_origin?

          if Switchboard.converse(Regexp.last_match(1), JSON.parse(@env["rack.input"].read)["message"])
            [200, { "content-type" => "text/plain" }, ["ok"]]
          else
            respond_not_found!
          end
        else
          respond_not_found!
        end
      end

      def path = @env["PATH_INFO"]

      def request_method = @env["REQUEST_METHOD"].upcase

      def respond_not_found!
        [404, { "content-type" => "text/plain" }, ["not found"]]
      end

      def sse_headers
        {
          "content-type"      => "text/event-stream",
          "x-accel-buffering" => "no",
          "last-modified"     => Time.now.httpdate,
        }
      end

      def valid_origin?
        @env["HTTP_ORIGIN"].include?(@env["HTTP_HOST"])
      end
    end
  end
end
