# frozen_string_literal: true

require_relative "user_identifier"

module Phlex
  module Chatbot
    module Chat
      class Message < Phlex::HTML
        attr_reader :message

        def initialize(message:, with_status_indicator: false)
          @message = message
          @with_status_indicator = with_status_indicator
        end

        def view_template
          message_class = message[:from_user] ? "pcb__message__user" : "pcb__message__bot"
          message_class += " pcb__message__bot-loading" if @with_status_indicator

          div(class: "pcb__message #{message_class}") do
            div(class: "pcb__status-indicator") { "Retrieving relevant documents" } if @with_status_indicator

            render UserIdentifier.new(from_system: !message[:from_user], user_name: message[:user_name])

            div class: "pcb__message__content" do
              if block_given?
                yield
              else
                plain message[:content]
              end
            end

            if message[:sources]
              div class: "pcb__message__footnotes" do
                message[:sources].each_with_index do |source, index|
                  span class: "pcb__footnote",
                       data_action: "click->chat-messages#showSource",
                       data_chat_messages_source_value: source.to_json do
                    plain "[#{index + 1}]"
                  end
                end
              end
            end
            unless message[:from_user]
              div class: "pcb__message__actions" do
                button data_action: "click->chat-messages#copyMessage" do
                  plain "Copy"
                end
                button data_action: "click->chat-messages#regenerateResponse" do
                  plain "Regenerate"
                end
              end
            end
          end
        end
      end
    end
  end
end
