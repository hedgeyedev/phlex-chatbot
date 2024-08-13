# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class Messages < Phlex::HTML
        def initialize(messages:)
          @messages = messages
        end

        def view_template
          div class: "hcb__chat-messages",
              data_chat_form_target: "messagesContainer",
              data_controller: "chat-messages" do
            @messages.each { |message| render Message.new(message:) }
          end
        end
      end
    end
  end
end
