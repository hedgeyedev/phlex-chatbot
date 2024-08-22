# frozen_string_literal: true

require "concurrent"
require "phlex"
require "rack"

require_relative "chatbot/channel"
require_relative "chatbot/chat"
require_relative "chatbot/null_logger"
require_relative "chatbot/status_component"
require_relative "chatbot/version"
require_relative "chatbot/web"

module Phlex
  module Chatbot
    class Error < StandardError; end
    ROOT_DIR = Pathname.new(__dir__).join("../..").expand_path

    def self.callback
      @callback
    end

    def self.callback=(callback)
      @callback = callback
    end

    def self.logger
      @logger ||= NullLogger.new(nil)
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.switchboard
      self.switchboard = :in_memory
      @switchboard
    end

    def self.switchboard=(name)
      return @switchboard if @switchboard

      require_relative "chatbot/switchboard/#{name}"
      cls_name = name.to_s.split('_').map(&:capitalize).join
      @switchboard = Switchboard.const_get(cls_name).instance
    end
  end
end
