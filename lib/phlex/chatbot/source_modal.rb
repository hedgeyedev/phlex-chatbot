# frozen_string_literal: true

module Phlex
  module Chatbot
    class SourceModal < Phlex::HTML
      def initialize(show_link: false)
        @show_link = show_link
      end

      def view_template
        div(
          class: "pcb__source-modal hide-modal",
          data: { pcb_source_modal_target: "modal" },
        ) do
          div(class: "pcb__source-modal-content") do
            h3(class: "pcb__source-modal-title", data_pcb_source_modal_target: "title")
            div(class: "pcb__source-modal-description", data_pcb_source_modal_target: "content") do
              blockquote(class: "pcb__source-modal-quote")
            end
            div(class: "pcb__source-modal-actions") do
              # TODO(Chris): Make this a slot for actions. "Close" is a default action. We can add more using Ref.

              if @show_link
                a(href: "", target: "_blank", class: "pcb__source-modal-link", data_pcb_source_modal_target: "link") do
                  "Visit source"
                end
              end

              # Spacer
              div

              button(data: { action: "pcb-source-modal#hide" }, class: "pcb__source-modal-close") { "Close" }
            end
          end
        end
      end
    end
  end
end
