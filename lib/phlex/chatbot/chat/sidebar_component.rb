# frozen_string_literal: true

require_relative "component"

module Phlex
  module Chatbot
    module Chat
      class SidebarComponent < Phlex::HTML
        class ActivatorButton < Phlex::SVG
          def view_template
            svg(class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
              path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M14 5l-7 7 7 7")
            end
          end
        end

        def initialize(messages:)
          @messages = messages
        end

        def view_template
          span(data: { controller: "pcb-sidebar", pcb_sidebar_active_class: "pcb__sidebar-activator__deactivate" }) do
            div(class: "pcb__sidebar", data: { pcb_sidebar_target: "sidebar" }) do
              render Component.new(messages: @messages)
            end
            button class: "pcb__sidebar-activator",
                   data: { action: "click->pcb-sidebar#toggle", pcb_sidebar_target: "toggleButton" } do
              render ActivatorButton.new
            end
          end
        end
      end
    end
  end
end
