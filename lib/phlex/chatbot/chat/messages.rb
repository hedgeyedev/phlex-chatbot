# frozen_string_literal: true

require_relative "message"

module Phlex
  module Chatbot
    module Chat
      class Messages < Phlex::HTML
        def initialize(messages: [])
          @messages = messages
        end

        def view_template
          div(
            id: "pcb-chat-messages",
            class: "pcb__chat-messages",
            data_controller: "pcb-chat-messages",
          ) do
            if block_given?
              yield
            else
              @messages.each do |message|
                render Message.new(**message)
              end
            end
          end
        end
      end
    end
  end
end
