# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        def view_template
          div class: "pcb__chat-input" do
            form data_action: "submit->chat-form#submit" do
              textarea placeholder: "Type your message...",
                       rows: "1",
                       data_chat_form_target: "input",
                       data_action: "keydown->chat-form#handleKeydown input->chat-form#resetTextareaHeight" do; end
              button(type: "submit") { "Send" }
            end
          end
        end
      end
    end
  end
end
