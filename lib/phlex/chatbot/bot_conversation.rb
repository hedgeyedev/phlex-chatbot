# frozen_string_literal: true

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

      # This is public for the sake of Rack's hijack API. It should not be used directly.
      def call(event_stream)
        @subscribers << event_stream
        send_event(:joined, data: { subscribers: @subscribers.size })
      end

      def send_failure!(error)
        send_event(:failure, data: { message: error.message })
        puts error.backtrace
      end

      def send_response!(message:)
        send_event(:response, data: { message: message })
      end

      def send_status!(message:)
        send_event(:status, data: { message: message })
      end

      def start_conversation!(data)
        callback.call(self, data)
      rescue StandardError => e
        send_failure!(e)
      end

      private

      def send_event(event, data:)
        removals = Set.new
        subscribers.each do |io|
          begin
            io.write("event: #{event}\n")
            io.write(prefix_data(JSON.pretty_generate(data.merge(subscribers: subscribers.size))))
            io.write("\n\n") # required by the SSE protocol
          end
        rescue Errno::EPIPE => _e
          removals << io
        end
        removals.each { |e| subscribers.delete(e) }
        self.class.destroy(token) if subscribers.empty?
      end

      def prefix_data(data)
        data.split("\n").map { |line| "data: #{line}" }.join("\n")
      end
    end
  end
end
