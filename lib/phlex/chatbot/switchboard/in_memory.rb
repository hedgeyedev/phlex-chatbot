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

        def create(id, callback)
          # TODO: salt this thing, track it, expire it, invalidate it, etc.
          (channels[id] ||= Channel.new(id, callback)).channel_id
        end

        def find(channel_id)
          channels[channel_id]
        end
      end
    end
  end
end
