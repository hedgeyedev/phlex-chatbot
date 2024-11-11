# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class Source < Phlex::HTML
        attr_reader :index, :source

        def initialize(index:, source:, classes: "pcb__footnote")
          @index  = index
          @source = source
          @classes = classes
        end

        def view_template(&block)
          a(
            href: "#",
            class: @classes,
            data: {
              action: "chatbot-modal#show",
              chatbot_modal_title_param: source[:title],
              chatbot_modal_content_param: source[:description],
              chatbot_modal_link_param: source[:url],
            },
          ) { "[#{index}]" }
        end
      end
    end
  end
end
