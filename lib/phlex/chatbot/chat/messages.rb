# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Messages < Phlex::HTML
        def initialize(messages:)
          @messages = messages
        end

        def view_template
          div class: "pcb__messages" do
            div class: "pcb__chat-messages",
                data_chat_form_target: "messagesContainer",
                data_controller: "chat-messages" do
              @messages.each { |message| render Message.new(message:) }
            end
          end
        end
      end
    end
  end
end
