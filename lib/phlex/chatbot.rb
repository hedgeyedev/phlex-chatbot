# frozen_string_literal: true

require "concurrent"
require "phlex"
require "rack"

require_relative "chatbot/channel"
require_relative "chatbot/chat"
require_relative "chatbot/conversator"
require_relative "chatbot/null_logger"
require_relative "chatbot/status_component"
require_relative "chatbot/switchboard/base"
require_relative "chatbot/version"
require_relative "chatbot/web"

module Phlex
  module Chatbot
    class Error < StandardError; end
    ROOT_DIR = Pathname.new(__dir__).join("../..").expand_path

    def self.allow_error_messages?
      @allow_error_messages
    end

    def self.allow_error_messages!
      @allow_error_messages = true
    end

    def self.conversator(channel_id:)
      @conversator.create(channel_id)
    end

    def self.conversator=(conversator)
      @conversator = conversator
    end
    self.conversator = Phlex::Chatbot::Conversator

    def self.disallow_error_messages!
      @allow_error_messages = false
    end

    def self.logger
      @logger ||= NullLogger.new(nil)
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.switchboard
      @switchboard ||= "in_memory"
      require_relative "chatbot/switchboard/#{@switchboard}"
      cls_name = @switchboard.to_s.split("_").map(&:capitalize).join
      Switchboard.const_get(cls_name).instance
    end

    def self.switchboard=(name)
      @switchboard = name
    end
  end
end
