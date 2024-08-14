# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Header < Phlex::HTML
        def initialize(full_page)
          @full_page = full_page
        end

        def view_template
          header class: "pcb__header" do
            h1 { "AI Chat" }
            div class: "flex space-x-2" do
              button data_action: "click->chat-messages#clearChat" do
                plain "Clear chat"
                button data_action: "click->chat-messages#toggleDarkMode" do
                  plain "Toggle dark mode"
                end
              end
            end
          end
        end
      end
    end
  end
end
