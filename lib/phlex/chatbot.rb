# frozen_string_literal: true

require_relative "chatbot/version"

module Phlex
  # Chatbot module
  module Chatbot
    class Error < StandardError; end

    autoload :Chat, "phlex/chatbot/chat"
    autoload :StatusComponent, "phlex/chatbot/status_component"

    # Rack app to serve the chatbot assets
    class Web
      def self.call(env)
        new(env).call
      end

      def initialize(env)
        @env = env
      end

      def call
        content_type, content = determine_content
        if content_type
          [200, { "Content-Type" => content_type }, [content]]
        else
          [404, { "Content-Type" => "text/plain" }, "not found"]
        end
      end

      private

      def chat_css
        File.read(File.expand_path("../../src/phlex_chatbot.css", __dir__))
      end

      def chat_js
        File.read(File.expand_path("../../src/phlex_chatbot.js", __dir__))
      end

      def determine_content
        case @env["PATH_INFO"]
        when "/js"
          ["application/javascript", chat_js]
        when "/css"
          ["text/css", chat_css]
        else
          [nil]
        end
      end
    end
  end
end
