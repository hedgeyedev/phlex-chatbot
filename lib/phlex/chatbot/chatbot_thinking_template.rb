module Phlex
  module Chatbot
    class ChatbotThinkingTemplate < Phlex::HTML
      def view_template
        template_tag(id: "chatbot-thinking-template") do

          render Chat::Message.new(message: {}, with_status_indicator: true) do
            div(class: "pcb__loading-line")
            div(class: "pcb__loading-line")
            div(class: "pcb__loading-line")
          end

        end
      end
    end
  end
end
