# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        def view_template
          div(class: "pcb__chat-input") do
            form(data: { action: "submit->pcb-chat-form#submit" }) do
              textarea(
                placeholder: "Type your message...",
                rows: "1",
                data: {
                  pcb_chat_form_target: "input",
                  action: "keydown->pcb-chat-form#handleKeydown input->pcb-chat-form#resetTextareaHeight",
                },
              )
              button(type: "submit") { "Send" }
            end
          end
        end
      end
    end
  end
end
