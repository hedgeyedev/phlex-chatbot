# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        SELECTOR = "chatbot-input"

        include Phlex::Rails::Helpers::TurboFrameTag
        include Phlex::Rails::Helpers::FormWith

        def initialize(chat_thread:)
          @chat_message = chat_thread.chat_messages.new
        end

        def view_template
          turbo_frame_tag(SELECTOR) do
            div(class: "pcb__chat-input") do
              form_with(
                model: @chat_message,
                remote: true,
                data: { controller: "pcb-chat-form" }
              ) do |form|
                form.text_area(
                  :user_input,
                  placeholder: "Type your message...",
                  rows: "1",
                )
                form.submit(
                  "Send",
                  class: "px-4 py-2 rounded bg-blue-500 text-white focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-blue-600 dark:hover:bg-blue-700",

                )
              end
            end
          end
        end
      end
    end
  end
end
