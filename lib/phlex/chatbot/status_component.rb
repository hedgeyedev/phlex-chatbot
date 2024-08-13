# frozen_string_literal: true

module Phlex
  module Chatbot
    class StatusComponent < Phlex::HTML
      def initialize(status:)
        @status = status
      end

      def view_template
        div class: "pcb__chat-status" do
          plain @status
        end
      end
    end
  end
end
