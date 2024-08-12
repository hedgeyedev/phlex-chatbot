# frozen_string_literal: true

module Hedgeye
  module Chatbot
    class StatusComponent < Phlex::HTML
      def initialize(status:)
        @status = status
      end

      def view_template
        div class: "chat-status" do
          plain @status
        end
      end
    end
  end
end
