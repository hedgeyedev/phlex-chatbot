# frozen_string_literal: true

module Phlex
  module Chatbot
    module Switchboard

      def self.converse(channel_id, message)
        InMemory.instance.converse(channel_id, message)
      end

      def self.create(id, callback)
        InMemory.instance.create(id, callback)
      end

      def self.destroy(channel_id)
        InMemory.instance.destroy(channel_id)
      end

      def self.find(channel_id)
        InMemory.instance.find(channel_id)
      end

      class Base
        attr_reader :channels

        def converse(channel_id, message)
          the_channel = find(channel_id)
          return false unless the_channel

          the_channel.send_ack!(message: message)
          the_channel.send_status!(message: "Asking the oracle")

          future = Concurrent::Promises.future_on(:io, the_channel, message) do |channel, data|
            channel.start_conversation!(data)
          rescue StandardError => e
            channel.send_failure!(e)
          end

          future.on_rejection { |error| Chatbot.logger.error error }

          true
        end

        def destroy(channel_id)
          channels.delete(channel_id)
        end
      end
    end
  end
end
