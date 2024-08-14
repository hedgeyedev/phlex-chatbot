require_relative "user_identifier"

module Phlex
  module Chatbot
    module Chat
      class Message < Phlex::HTML
        attr_reader :message

        def initialize(message:, with_status_indicator: false, message_index: nil)
          @message = message
          @with_status_indicator = with_status_indicator
          @message_index = message_index
        end

        def view_template
          message_class = message[:from_user] ? "pcb__message__user" : "pcb__message__bot"
          user_target_data = message[:from_user] ? "message" : ""
          message_class += " pcb__message__bot-loading" if @with_status_indicator

          div(class: "pcb__message #{message_class}",
              data_chat_messages_target: user_target_data) do
            div(class: "pcb__status-indicator") { "Retrieving relevant documents" } if @with_status_indicator

            render UserIdentifier.new(from_system: !message[:from_user], user_name: message[:user_name])

            div class: "pcb__message__content" do
              if block_given?
                yield
              else
                plain message[:content]
              end
            end

            render_sources if message[:sources]

            render_actions unless message[:from_user]
          end
        end

        private

        def render_sources
          div class: "pcb__message__footnotes" do
            message[:sources].each.with_index(1) do |source, index|
              a(href: "#",
                class: "pcb__footnote",
                data_action: "click->chat-messages#showSource:prevent",
                data_chat_messages_source_title_param: source[:title],
                data_chat_messages_source_description_param: source[:description],
                data_chat_messages_source_url_param: source[:url]
              ) do
                plain "[#{index}]"
              end
            end
          end
        end

        def render_actions
          div class: "pcb__message__actions" do
            button data_action: "click->chat-messages#copyMessage" do
              plain "Copy"
            end
            button data_action: "click->chat-messages#regenerateResponse" do
              plain "Regenerate"
            end
          end
        end
      end
    end
  end
end
