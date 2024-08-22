# frozen_string_literal: true

require_relative "base"

module Phlex
  module Chatbot
    module Switchboard
      class InMemory < Base
        include Singleton

        def initialize
          @channels ||= Concurrent::Hash.new
        end

        def create(channel_id)
          (channels[channel_id] ||= Channel.new(channel_id, Phlex::Chatbot.callback)).channel_id
        end

        def extend_ttl(channel_id)
          nil
        end

        def find(channel_id)
          channels[channel_id]
        end
      end
    end
  end
end
