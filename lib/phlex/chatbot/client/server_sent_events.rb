# frozen_string_literal: true

module Phlex
  module Chatbot
    module Client
      class ServerSentEvents
        def initialize(io)
          @io = io
        end

        def close
          @io.close rescue nil # rubocop:disable Style/RescueModifier
        end

        def send_event(event, data)
          @io.write("event: #{event}\n")
          @io.write(prefix_data(JSON.pretty_generate(data: data)))
          @io.write("\n\n") # required by the SSE protocol
        end

        private

        def prefix_data(data)
          data.split("\n").map { |line| "data: #{line}" }.join("\n")
        end
      end
    end
  end
end
