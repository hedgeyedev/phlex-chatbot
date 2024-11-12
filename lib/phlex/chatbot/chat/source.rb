# frozen_string_literal: true

require_relative "../modals/reference"

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

        # Add "Link" action to the modal

        def view_template
          render Phlex::Chatbot::Modals::Reference.new(
            title: source[:title],
            content: source[:description],
            link: source[:url],
            classes: @classes,
          ) { "[#{index}]" }
        end
      end
    end
  end
end
