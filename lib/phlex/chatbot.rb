# frozen_string_literal: true

require "langchain"
require "openai"

require_relative "chatbot/version"

module Phlex
  # Chatbot module
  module Chatbot
    class Error < StandardError; end

    autoload :Chat, "phlex/chatbot/chat"
    autoload :StatusComponent, "phlex/chatbot/status_component"

    class Bot
      attr_reader :id, :subscribers

      def self.bots
        @bots ||= {}
      end

      def self.create(id)
        bots[id] ||= new(id)
      end

      def self.destroy(id)
        bots.delete(id)
      end

      def self.send_event(id, event, data:)
        bot = bots[id]
        bot&.send_event(event, data: data)
        !bot.nil?
      end

      def initialize(id)
        @id = id
        @subscribers = Set.new
      end

      def call(io)
        @subscribers << io
        send_event(:joined, data: { id: @id, subscribers: @subscribers.size })
      end

      def send_event(event, data:)
        removals = Set.new
        @subscribers.each do |io|
          begin
            io.write("event: #{event}\n")
            io.write(message(JSON.pretty_generate(data.merge(subscribers: @subscribers.size))))
            io.write("\n\n")
          end
        rescue Errno::EPIPE => e
          removals << io
        end
        @subscribers -= removals
        Bot.destroy(@id) if @subscribers.empty?
      end

      def message(data)
        data.split("\n").map { |line| "data: #{line}" }.join("\n")
      end
    end

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
        when %r{/bot/([a-fA-F0-9]+$)}
          [200, { "content-type" => "text/event-stream" }, Bot.create(Regexp.last_match(1))]
        else
          [404, { "content-type" => "text/plain" }, ["not found"]]
        end
      end

      def post
        case path
        when %r{/bot/([a-fA-F0-9]+$)}
          data = @env["rack.input"].read
          ok = true
          id = Regexp.last_match(1)

          Thread.start do
            Bot.send_event(id, :status, data: { message: "Retrieving relevant documents" })
            openai_api_key = ENV.fetch("OPENAI_API_KEY", "fakeopenaiapikey")
            llm = Langchain::LLM::OpenAI.new(api_key: openai_api_key)
            sleep(1)
            Bot.send_event(id, :status, data: { message: "Asking the oracle" })
            begin
              chat = llm.chat(messages: [{role: "user", content: data}])
              Bot.send_event(id, :response, data: { message: chat.chat_completion })
            rescue StandardError => e
              Bot.send_event(id, :response, data: { message: "Error: #{e.message}" })
            end
          end

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

      def path = @env["PATH_INFO"]

      def css
        File.read(File.expand_path("../../dist/bot.css", __dir__))
      end

      def js
        File.read(File.expand_path("../../dist/bot.js", __dir__))
      end

      def js_map
        File.read(File.expand_path("../../dist/bot.js.map", __dir__))
      end
    end
  end
end
