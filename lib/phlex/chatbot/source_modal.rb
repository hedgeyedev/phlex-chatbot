# frozen_string_literal: true

module Phlex
  module Chatbot
    class SourceModal < Phlex::HTML
      def view_template
        div(
          class: "pcb__source-modal hide-modal",
          data: { chatbot_modal_target: "modal" },
        ) do
          div(class: "pcb__source-modal-content") do
            h3(class: "pcb__source-modal-title", data_chatbot_modal_target: "title")
            div(class: "pcb__source-modal-description", data_chatbot_modal_target: "content") do
              blockquote(class: "pcb__source-modal-quote")
            end
            div(class: "pcb__source-modal-actions") do
              # This is a slot for actions. "Close" is a default action. We can add more using Ref.
              a(href: "", target: "_blank", class: "pcb__source-modal-link", data_chatbot_modal_target: "link") { "Visit source" }



              button(data: { action: "chatbot-modal#hide" }, class: "pcb__source-modal-close") { "Close" }
            end
          end
        end
      end
    end
  end
end
