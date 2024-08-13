module Phlex
  module Chatbot
    class ChatbotMessageTemplate < Phlex::HTML
      def view_template
        template_tag(id: "chatbot-message-template") do
          render Chat::Message.new(message: {})
        end
      end
    end
  end
end
