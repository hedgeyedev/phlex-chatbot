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
                  action: <<~ACTIONS.squish,
                    keydown.ctrl+enter->pcb-chat-form#handleKeyboardSubmit:prevent
                    keydown.meta+enter->pcb-chat-form#handleKeyboardSubmit:prevent
                    input->pcb-chat-form#resetTextareaHeight
                  ACTIONS
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
