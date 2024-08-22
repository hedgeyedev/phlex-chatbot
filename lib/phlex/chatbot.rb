# frozen_string_literal: true

require "concurrent"
require "phlex"
require "rack"

require_relative "chatbot/channel"
require_relative "chatbot/switchboard/in_memory"
require_relative "chatbot/chat"
require_relative "chatbot/null_logger"
require_relative "chatbot/status_component"
require_relative "chatbot/version"
require_relative "chatbot/web"

module Phlex
  module Chatbot
    class Error < StandardError; end
    ROOT_DIR = Pathname.new(__dir__).join("../..").expand_path

    def self.logger
      @logger ||= NullLogger.new(nil)
    end

    def self.logger=(logger)
      @logger = logger
    end
  end
end
