# frozen_string_literal: true

require_relative "header"
require_relative "input"
require_relative "messages"

require_relative "../chatbot_message_template"
require_relative "../chatbot_thinking_template"
require_relative "../user_message_template"
require_relative "../source_modal"

module Phlex
  module Chatbot
    module Chat
      class Component < Phlex::HTML
        def initialize(messages:, full_page: false)
          @messages = messages
          @full_page = full_page
        end

        def view_template
          div(
            **classes("pcb pcb__chat-container", full_page?: "full_page"),
            data: { controller: "pcb-chat-form pcb-chat-messages" }
          ) { chat_content! }

          templates!
        end

        private

        def chat_content!
          render Header.new(@full_page)
          render Messages.new(messages: @messages)
          render Input.new
        end

        def full_page? = @full_page

        def templates!
          render Phlex::Chatbot::SourceModal.new
          render Phlex::Chatbot::ChatbotMessageTemplate.new
          render Phlex::Chatbot::ChatbotThinkingTemplate.new
          render Phlex::Chatbot::UserMessageTemplate.new
        end
      end
    end
  end
end
