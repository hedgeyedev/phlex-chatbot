# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class Messages < Phlex::HTML
        def initialize(messages:)
          @messages = messages
        end

        def view_template
          div class: "chat-messages flex flex-col space-y-4 p-4",
              data_chat_form_target: "messagesContainer",
              data_controller: "chat-messages",
              style: "max-height: 70vh; overflow-y: auto;" do
            @messages.each do |message|
              message_class = message[:from_user] ? "self-end bg-green-100" : "self-start bg-gray-100"
              div class: "message min-w-[200px] max-w-[70%] p-3 rounded-lg #{message_class}" do
                div class: "flex items-center mb-2" do
                  if message[:from_user]
                    div class: "w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold mr-2" do
                      plain "UN"
                    end
                    span class: "font-semibold" do
                      plain "User Name"
                    end
                  else
                    div class: "w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold mr-2" do
                      plain "AI"
                    end
                    span class: "font-semibold" do
                      plain "AI Assistant"
                    end
                  end
                end
                div class: "message-content" do
                  plain message[:content]
                end
                if message[:sources]
                  div class: "message-footnotes mt-2 text-sm text-gray-500" do
                    message[:sources].each_with_index do |source, index|
                      span class: "footnote cursor-pointer text-blue-500 hover:text-blue-700 mr-2",
                          data_action: "click->chat-messages#showSource",
                          data_chat_messages_source_value: source.to_json do
                        plain "[#{index + 1}]"
                      end
                    end
                  end
                end
                if !message[:from_user]
                  div class: "message-actions mt-2 flex space-x-2" do
                    button class: "text-sm text-gray-500 hover:text-gray-700", data_action: "click->chat-messages#copyMessage" do
                      plain "Copy"
                    end
                    button class: "text-sm text-gray-500 hover:text-gray-700", data_action: "click->chat-messages#regenerateResponse" do
                      plain "Regenerate"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
