# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        def initialize
        end

        def view_template
          div(class: "pcb__chat-input") do
            form do
              textarea(placeholder: "Type your message...")
              submit(
                class: "px-4 py-2 rounded bg-blue-500 text-white focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-blue-600 dark:hover:bg-blue-700"
              ) do
                "Send"
              end
            end
          end
        end
      end
    end
  end
end
