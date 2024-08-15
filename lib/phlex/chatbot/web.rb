# frozen_string_literal: true

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
        when "GET" then get
        when "POST" then post
        else raise "Unsupported request method: #{request_method}"
        end
      end

      private

      def get
        case path
        when "/bot.css"
          [200, { "content-type" => "text/css" }, [css]]
        when "/bot.js"
          [200, { "content-type" => "application/javascript" }, [js]]
        when "/bot.js.map"
          [200, { "content-type" => "application/javascript" }, [js_map]]
        when %r{/join/([a-fA-F0-9]+$)}
          # this id comes from the host app, ostensibly after it has called our API to create a conversation
          bot = BotConversation.find(Regexp.last_match(1))
          if bot
            [200, { "content-type" => "text/event-stream" }, bot]
          else
            respond_not_found!
          end
        else
          respond_not_found!
        end
      end

      def post
        case path
        when %r{/ask/([a-fA-F0-9]+$)}
          ok = true

          BotConversation.converse(Regexp.last_match(1), @env["rack.input"].read)

          if ok
            [200, { "content-type" => "text/plain" }, ["ok"]]
          else
            [404, { "content-type" => "text/plain" }, ["not found"]]
          end
        else
          [404, { "content-type" => "text/plain" }, ["not found"]]
        end
      end

      def request_method = @env["REQUEST_METHOD"].upcase

      def respond_not_found!
        [404, { "content-type" => "text/plain" }, ["not found"]]
      end

      def path = @env["PATH_INFO"]

      def css
        File.read(File.join(ROOT_DIR, "dist", "bot.css"))
      end

      def js
        File.read(File.join(ROOT_DIR, "dist", "bot.js"))
      end

      def js_map
        File.read(File.join(ROOT_DIR, "dist", "bot.js.map"))
      end
    end
  end
end
