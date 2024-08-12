# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        def view_template
          div class: "chat-input border-t border-gray-200 p-4 bg-white mt-2" do
            form class: "flex items-center space-x-2", data_action: "submit->chat-form#submit" do
              textarea class: "flex-grow p-2 border rounded resize-none focus:outline-none focus:ring-2 focus:ring-blue-500",
                      placeholder: "Type your message...",
                      rows: "1",
                      data_chat_form_target: "input",
                      data_action: "keydown->chat-form#handleKeydown input->chat-form#resetTextareaHeight" do; end
              button type: "submit", class: "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500" do
                plain "Send"
              end
            end
          end
        end
      end
    end
  end
end
