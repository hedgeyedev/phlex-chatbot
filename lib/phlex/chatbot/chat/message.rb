# frozen_string_literal: true

require_relative "user_identifier"

module Phlex
  module Chatbot
    module Chat
      class Message < Phlex::HTML
        attr_reader :avatar, :from_user, :message, :sources, :status_message, :user_name

        def initialize( # rubocop:disable Metrics/ParameterLists
          message:,
          additional_message_actions: nil,
          avatar: nil,
          from_user: false,
          sources: nil,
          status_message: nil,
          user_name: nil,
          **_others
        )
          @additional_message_actions = additional_message_actions
          @avatar                     = avatar
          @from_user                  = from_user
          @message                    = message
          @sources                    = sources
          @status_message             = status_message
          @user_name                  = user_name
        end

        def view_template
          message_class = from_user ? "pcb__message__user" : "pcb__message__bot"
          user_target_data = from_user ? "message" : ""
          message_class += " pcb__message__bot-loading" if status_message

          div(
            id: status_message ? "current_status" : nil,
            class: "pcb__message #{message_class}",
            data_chat_messages_target: user_target_data,
          ) do
            div(class: "pcb__status-indicator") { status_message } if status_message

            render UserIdentifier.new(avatar: avatar, from_system: !from_user, user_name: user_name)

            div class: "pcb__message__content" do
              if block_given?
                yield
              else
                unsafe_raw message
              end
            end

            render_sources if sources

            render_actions unless from_user
          end
        end

        private

        def render_sources
          div class: "pcb__message__footnotes" do
            sources.each.with_index(1) do |source, index|
              a(
                href: "#",
                class: "pcb__footnote",
                data: {
                  action: "click->pcb-chat-messages#showSource:prevent",
                  pcb_chat_messages_source_title_param: source[:title],
                  pcb_chat_messages_source_description_param: source[:description],
                  pcb_chat_messages_source_url_param: source[:url],
                },
              ) { "[#{index}]" }
            end
          end
        end

        def render_actions
          div class: "pcb__message__actions" do
            button(data: { action: "click->pcb-chat-messages#copyMessage" }) { "Copy" }
            button(data: { action: "click->pcb-chat-messages#regenerateResponse" }) { "Regenerate" }
            @additional_message_actions&.each do |component_callback|
              render component_callback.call(self)
            end
          end
        end
      end
    end
  end
end
