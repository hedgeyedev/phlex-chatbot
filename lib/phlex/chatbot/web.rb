# frozen_string_literal: true

require_relative "client/web_socket"

module Phlex
  module Chatbot
    # Rack app to serve the chatbot assets

    class Web
      class HijackMissing < ::Phlex::Chatbot::Error; end

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
          bot = BotConversation.find(Regexp.last_match(1))
          return respond_not_found! unless bot

          if @env["HTTP_UPGRADE"]&.starts_with?("websocket")
            # WebSocket
            return respond_not_found! unless valid_origin?

            bot.subscribe(Client::WebSocket.new(@env, bot.token))
            [-1, {}, []]
          elsif @env["HTTP_ACCEPT"]&.include?("text/event-stream")
            # SSE
            # Note: we don't really understand why we have to return bot as part of the response but that is how the
            # client gets subscribed to the channel.
            [200, sse_headers, bot]
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

          if BotConversation.converse(Regexp.last_match(1), JSON.parse(@env["rack.input"].read)["message"])
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
