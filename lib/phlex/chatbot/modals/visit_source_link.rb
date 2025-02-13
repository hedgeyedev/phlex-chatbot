# frozen_string_literal: true

module Phlex
  module Chatbot
    module Modals
      class VisitSourceLink < Phlex::HTML
        def view_template
          a(href: "", target: "_blank", class: "pcb__source-modal-link", data_pcb_source_modal_target: "link") do
            "Visit source"
          end
        end
      end
    end
  end
end
