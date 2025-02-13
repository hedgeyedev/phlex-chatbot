# frozen_string_literal: true

module Phlex
  module Chatbot
    module Modals
      class CloseButton < Phlex::HTML
        def view_template
          button(data: { action: "pcb-source-modal#hide" }, class: "pcb__source-modal-close") { "Close" }
        end
      end
    end
  end
end
