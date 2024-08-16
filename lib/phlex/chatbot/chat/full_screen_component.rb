# frozen_string_literal: true

require_relative "component"

module Phlex
  module Chatbot
    module Chat
      class FullScreenComponent < Phlex::HTML
        def initialize(conversation_token:, endpoint:, messages:)
          @conversation_token = conversation_token
          @endpoint           = endpoint
          @messages           = messages
        end

        def view_template
          render Component.new(
            conversation_token: @conversation_token,
            endpoint: @endpoint,
            messages: @messages,
            full_page: true,
          )
        end
      end
    end
  end
end
