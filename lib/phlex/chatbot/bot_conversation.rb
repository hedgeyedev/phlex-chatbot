# frozen_string_literal: true

require_relative "client/server_sent_events"
require_relative "client/web_socket"

module Phlex
  module Chatbot
    class BotConversation
      attr_reader :callback, :subscribers, :token

      def self.bots
        @bots ||= Concurrent::Hash.new
      end

      def self.converse(token, message)
        the_bot = bots[token]
        return false unless the_bot

        the_bot.send_ack!(message: message)
        the_bot.send_status!(message: "Asking the oracle")

        future = Concurrent::Promises.future_on(:io, the_bot, message) do |bot, data|
          bot.start_conversation!(data)
        rescue StandardError => e
          bot.send_failure!(e)
        end

        future
          .on_fulfillment { |result| puts result }
          .on_rejection { |error| puts error }

        true
      end

      def self.create(id, callback)
        # TODO: salt this thing, track it, expire it, invalidate it, etc.
        (bots[id] ||= new(id, callback)).token
      end

      def self.find(token)
        bots[token]
      end

      def self.destroy(token)
        bots.delete(token)
      end

      def self.send_event(token, event, data:)
        bot = bots[token]
        bot&.send_event(event, data: data)
        !bot.nil?
      end

      def initialize(token, callback)
        @callback    = callback
        @token       = token
        @subscribers = Concurrent::Set.new
      end

      def subscribe_with_sse_io(io)
        client = Client::ServerSentEvents.new(io)
        @subscribers << client
        send_event(:joined, data: [])
      end

      # NOTE: We don't really understand why we have to do it this way for SSE
      alias call subscribe_with_sse_io

      # This is public for the sake of Rack's hijack API. It should not be used directly.
      def send_ack!(message:)
        send_event(:resp, data: [{ cmd: "append", element: Chat::Message.new(message: message, from_user: true).call }])
      end

      def send_failure!(error)
        send_event(:resp, data: [{ cmd: "append", element: Chat::Message.new(message: error.message).call }])
        puts error.backtrace
      end

      def send_response!(message:, sources: nil)
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: Chat::Message.new(message: message, sources: sources).call },
          ],
        )
      end

      def send_status!(message:)
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: ChatbotThinking.new(message).call },
          ],
        )
      end

      def start_conversation!(data)
        callback.call(self, data)
      rescue StandardError => e
        send_failure!(e)
      end

      def subscribe(client)
        @subscribers << client
        send_event(:joined, data: [])
      end

      private

      def send_event(event, data:)
        removals = Set.new
        subscribers.each do |sub|
          sub.send_event(event, data)
        rescue Errno::EPIPE => _e
          removals << sub
        end
        removals.each do |e|
          e.close rescue nil # rubocop:disable Style/RescueModifier
          subscribers.delete(e)
        end
        self.class.destroy(token) if subscribers.empty?
      end
    end
  end
end
