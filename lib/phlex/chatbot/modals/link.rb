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
              action: "pcb-source-modal#show",
              pcb_source_modal_title_param: @title,
              pcb_source_modal_content_param: @content,
              pcb_source_modal_link_param: @link,
            }, &
          )
        end
      end
    end
  end
end
