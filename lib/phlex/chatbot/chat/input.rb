# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Input < Phlex::HTML
        include Phlex::Rails::Helpers::TurboFrameTag
        include Phlex::Rails::Helpers::FormWith

        def initialize(chat_thread:)
          @chat_message = chat_thread.chat_messages.new
        end

        def view_template
          turbo_frame_tag("pcci-form") do
            div(class: "pcb__chat-input") do
              form_with(model: @chat_message, remote: true) do |form|
                form.text_area(
                  :user_input,
                  placeholder: "Type your message...",
                  rows: "1",
                )
                form.submit("Send", data: { disable_with: "Sending..." })
              end
            end
          end
        end
      end
    end
  end
end
