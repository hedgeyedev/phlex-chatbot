# frozen_string_literal: true

require_relative "header"
require_relative "input"
require_relative "messages"

require_relative "../chatbot_thinking"
require_relative "../source_modal"

module Phlex
  module Chatbot
    module Chat
      class Component < Phlex::HTML
        def initialize(conversation_token:, driver:, endpoint:, messages:, full_page: false)
          @conversation_token = conversation_token
          @driver             = driver
          @endpoint           = endpoint
          @full_page          = full_page
          @messages           = messages
        end

        def view_template
          div(
            **classes("pcb pcb__chat-container", full_page?: "full_page"),
            data: {
              controller: "pcb-chat-form pcb-chat-messages",
              pcb_chat_form_conversation_token_value: @conversation_token,
              pcb_chat_form_driver_value: @driver,
              pcb_chat_form_endpoint_value: @endpoint,
            },
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
        end
      end
    end
  end
end
