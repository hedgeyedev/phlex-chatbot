# frozen_string_literal: true

module Phlex
  module Chatbot
    class SourceModal < Phlex::HTML
      include Phlex::DeferredRender

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
              if @actions
                render @actions
              else
                render Phlex::Chatbot::Modals::VisitSourceLink.new
                render Phlex::Chatbot::Modals::CloseButton.new
              end
            end
          end
        end
      end

      def actions(&block)
        @actions = block
      end
    end
  end
end
