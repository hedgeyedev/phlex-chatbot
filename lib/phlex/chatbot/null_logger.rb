# frozen_string_literal: true

require "logger"

module Phlex
  module Chatbot
    class NullLogger < Logger
      def write(...)
        # Do nothing
      end
    end
  end
end
