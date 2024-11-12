module Phlex
  module Chatbot
    module Modals
      class Reference < Phlex::HTML
        def initialize(title: nil, content:, link: nil, classes: nil)
          @title = title
          @content = content
          @link = link
          @classes = classes
        end

        # Add slot for multiple actions

        def view_template
          a(
            href: "#",
            class: @classes,
            data: {
              action: "chatbot-modal#show",
              chatbot_modal_title_param: @title,
              chatbot_modal_content_param: @content,
              chatbot_modal_link_param: @link,
            },
          ) { yield }
        end
      end
    end
  end
end
