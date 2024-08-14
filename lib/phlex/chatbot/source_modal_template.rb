module Phlex
  module Chatbot
    class SourceModalTemplate < Phlex::HTML
      def initialize(source:, index:, message_index:)
        @source = source
        @index = index
        @message_index = message_index
      end

      def view_template
        div(
          class: "pcb__source-modal hide-modal",
          data: {
            controller: "source-modal",
            source_modal_target: "modal",
            index: @index,
            message_index: @message_index
          }
        ) do
          div(class: "pcb__source-modal-content") do
            h3 { @source[:title] }
            p { @source[:description] }
            a(href: @source[:url], target: "_blank") { "Visit source" }
            button(data: { action: "source-modal#closeModal" }) { "Close" }
          end
        end
      end
    end
  end
end
