# frozen_string_literal: true

require_relative "header"
require_relative "input"
require_relative "messages"

module Phlex
  module Chatbot
    module Chat
      class Component < Phlex::HTML
        def initialize(messages:, full_page: false)
          @messages = messages
          @full_page = full_page
        end

        def view_template
          div(class: "pcb pcb__chat-container", data_controller: "chat-form chat-messages") { chat_content! }
        end

        private

        def chat_content!
          render Header.new(@full_page)
          render Messages.new(messages: @messages)
          render Input.new
        end
      end
    end
  end
end
