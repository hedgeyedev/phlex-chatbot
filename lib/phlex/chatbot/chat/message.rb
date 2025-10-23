# frozen_string_literal: true

require_relative "user_identifier"

module Phlex
  module Chatbot
    module Chat
      class Message < Phlex::HTML
        include Phlex::DeferredRender
        include Phlex::Rails::Helpers::Sanitize

        attr_reader :avatar, :from_user, :message, :user_name

        def initialize(
          message:,
          avatar: nil,
          from_user: false,
          user_name: nil,
          id: nil,
          **html_attrs
        )
          @avatar                     = avatar
          @from_user                  = from_user
          @message                    = message
          @user_name                  = user_name
          @id                         = id
          @other_attrs                = html_attrs
        end

        def view_template
          classes = tokens(
            "pcb__message",
            from_user ? "pcb__message__user" : "pcb__message__bot",
            @other_attrs.delete(:class),
          )

          div(
            id: @id,
            class: classes,
            **@other_attrs,
          ) do
            render @header if @header

            render UserIdentifier.new(avatar: avatar, from_system: !from_user, user_name: user_name)

            content class: "pcb__message__content"

            render @footer if @footer
          end
        end

        def content(**attrs)
          div(**attrs) do
            if @body
              render @body
            else
              # Subclasses can override this method to render HTML if needed (e.g., for bot messages with markdown)
              sanitize message
            end
          end
        end

        def header(&block)
          @header = block
        end

        def body(&block)
          @body = block
        end

        def footer(&block)
          @footer = block
        end
      end
    end
  end
end
