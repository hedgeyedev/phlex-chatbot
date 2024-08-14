# frozen_string_literal: true

require_relative "header"
require_relative "input"
require_relative "messages"

require_relative "../chatbot_message_template"
require_relative "../chatbot_thinking_template"
require_relative "../user_message_template"
require_relative "../source_modal_template"

module Phlex
  module Chatbot
    module Chat
      class Component < Phlex::HTML
        def initialize(messages:, full_page: false)
          @messages = messages
          @full_page = full_page
        end

        def view_template
          div(class: "pcb pcb__chat-container #{" full-page" if @full_page}",
              data_controller: "chat-form chat-messages messagesContainer") do
            chat_content!
          end

          render_templates
        end

        private

        def chat_content!
          render Header.new(@full_page)
          render Messages.new(messages: @messages)
          render Input.new
        end

        def render_templates
          render Phlex::Chatbot::ChatbotMessageTemplate.new
          render Phlex::Chatbot::ChatbotThinkingTemplate.new
          render Phlex::Chatbot::UserMessageTemplate.new
          render_source_modals
        end

        def render_source_modals
          div(id: "pcb__source-modals", class: "hidden", data: { controller: "source-modal" }) do
            @messages.each_with_index do |message, message_index|
              next unless message[:sources]

              message[:sources].each_with_index do |source, source_index|
                render Phlex::Chatbot::SourceModalTemplate.new(
                  source:,
                  index: source_index,
                  message_index:
                )
              end
            end
          end
        end
      end
    end
  end
end
