# frozen_string_literal: true

module Phlex
  module Chatbot
    module Switchboard
      def self.converse(channel_id, message)
        Phlex::Chatbot.switchboard.converse(channel_id, message)
      end

      def self.create(id)
        Phlex::Chatbot.switchboard.create(id.to_s)
      end

      def self.destroy(channel_id)
        Phlex::Chatbot.switchboard.destroy(channel_id)
      end

      def self.extend_ttl(channel_id)
        Phlex::Chatbot.switchboard.extend_ttl(channel_id)
      end

      def self.find(channel_id)
        Phlex::Chatbot.switchboard.find(channel_id)
      end

      class Base
        attr_reader :channels

        def converse(channel_id, message)
          the_channel = find(channel_id)
          return false unless the_channel

          the_channel.send_ack!(message: message)

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
