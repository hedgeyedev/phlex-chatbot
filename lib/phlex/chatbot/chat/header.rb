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
            div do
              button(data: { action: "click->pcb-chat-messages#clearChat" }) { "Clear chat" }
              button(data: { action: "click->pcb-chat-messages#toggleDarkMode" }) { "Toggle dark mode" }
            end
          end
        end
      end
    end
  end
end
