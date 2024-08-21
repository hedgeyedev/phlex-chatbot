# frozen_string_literal: true

module Phlex
  module Chatbot
    class ChatbotThinking < Phlex::HTML
      def initialize(status)
        @status = status
      end

      def view_template
        render Chat::Message.new(message: nil, status_message: @status) do
          div(class: "pcb__loading-line")
          div(class: "pcb__loading-line")
          div(class: "pcb__loading-line")
        end
      end
    end
  end
end
