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
            h3(class: "pcb__source-modal-title") { @source[:title] }
            div(class: "pcb__source-modal-description") do
              blockquote(class: "pcb__source-modal-quote") do
                plain @source[:description]
              end
            end
            div(class: "pcb__source-modal-actions") do
              a(href: @source[:url], target: "_blank", class: "pcb__source-modal-link") { "Visit source" }
              button(data: { action: "source-modal#closeModal" }, class: "pcb__source-modal-close") { "Close" }
            end
          end
        end
      end
    end
  end
end
