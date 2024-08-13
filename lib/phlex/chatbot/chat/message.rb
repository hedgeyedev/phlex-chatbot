# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Message < Phlex::HTML
        def initialize(message:)
          @message = message
        end

        def view_template
          message_class = message[:from_user] ? "pcb__message__user" : "pcb__message__bot"
          div class: "pcb__message #{message_class}" do
            render UserIdentifier.new(from_system: !message[:from_user], user_name: message[:user_name])

            div class: "pcb__message-content" do
              plain message[:content]
            end

            if message[:sources]
              div class: "pcb__message-footnotes" do
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
              div class: "pcb__message-actions" do
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
