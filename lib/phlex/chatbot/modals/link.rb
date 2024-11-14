module Phlex
  module Chatbot
    module Modals
      class Link < Phlex::HTML
        def initialize(content:, title: nil, link: nil, classes: nil)
          @title = title
          @content = content
          @link = link
          @classes = classes
        end

        def view_template(&)
          a(
            href: "#",
            class: @classes,
            data: {
              action: "chatbot-modal#show",
              chatbot_modal_title_param: @title,
              chatbot_modal_content_param: @content,
              chatbot_modal_link_param: @link,
            }, &
          )
        end
      end
    end
  end
end
