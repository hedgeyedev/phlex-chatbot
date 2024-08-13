# frozen_string_literal: true

module Phlex
  module Chatbot
    class Sidebar < Phlex::HTML
      def initialize(messages:)
        @messages = messages
      end

      def view_template
        div class: "pcb__chat-sidebar" do
          render Chat::Component.new(messages: @messages, full_page: false)
        end
      end
    end
  end
end
