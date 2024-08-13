module Phlex
  module Chatbot
    class UserMessageTemplate < Phlex::HTML
      def view_template
        template_tag(id: "user-message-template") do
          render Chat::Message.new(message: { from_user: true })
        end
      end
    end
  end
end
