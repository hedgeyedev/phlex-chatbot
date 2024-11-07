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
              action: "click->pcb-chat-messages#showSource:prevent",
              pcb_chat_messages_source_title_param: source[:title],
              pcb_chat_messages_source_description_param: source[:description],
              pcb_chat_messages_source_url_param: source[:url],
            },
          ) { "[#{index}]" }
        end
      end
    end
  end
end
