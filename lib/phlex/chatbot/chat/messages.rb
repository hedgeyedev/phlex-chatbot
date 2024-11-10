# frozen_string_literal: true

require_relative "message"

module Phlex
  module Chatbot
    module Chat
      class Messages < Phlex::HTML
        def initialize(messages:)
          @messages = messages
        end

        def view_template
          div(
            id: "pcb-chat-messages",
            class: "pcb__chat-messages",
            data: {
              pcb_chat_form_target: "messagesContainer",
              pcb_chat_messages_target: "messagesContainer",
            },
          ) do
            @messages.each { |message| render Message.new(**message) }
          end
        end
      end
    end
  end
end
