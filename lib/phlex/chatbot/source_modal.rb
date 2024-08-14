module Phlex
  module Chatbot
    class SourceModal < Phlex::HTML
      def view_template
        div(
          class: "pcb__source-modal hide-modal",
          data: {
            controller: "source-modal",
            source_modal_target: "modal",
          }
        ) do
          div(class: "pcb__source-modal-content") do
            h3(class: "pcb__source-modal-title")
            div(class: "pcb__source-modal-description") do
              blockquote(class: "pcb__source-modal-quote")
            end
            div(class: "pcb__source-modal-actions") do
              a(href: "", target: "_blank", class: "pcb__source-modal-link") { "Visit source" }
              button(data: { action: "source-modal#closeModal" }, class: "pcb__source-modal-close") { "Close" }
            end
          end
        end
      end
    end
  end
end
