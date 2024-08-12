# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class Header < Phlex::HTML
        def initialize(full_page)
          @full_page = full_page
        end

        def view_template
          header class: "bg-white border-b border-gray-200 p-4 flex justify-between items-center" do
            h1 class: "text-xl font-bold" do
              plain "AI Chat"
            end
            div class: "flex space-x-2" do
              button class: "px-3 py-1 bg-gray-100 hover:bg-gray-200 rounded text-sm", data_action: "click->chat-messages#clearChat" do
                plain "Clear chat"
              end
              if @full_page
                button class: "px-3 py-1 bg-gray-100 hover:bg-gray-200 rounded text-sm", data_action: "click->chat-messages#toggleDarkMode" do
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
