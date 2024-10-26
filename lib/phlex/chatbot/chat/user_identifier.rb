# frozen_string_literal: true

module Phlex
  module Chatbot
    module Chat
      class UserIdentifier < Phlex::HTML
        AI_ASST = "AI Assistant"

        def initialize(avatar: nil, user_name: nil, from_system: false)
          @avatar        = avatar
          @from_system   = from_system
          @user_name     = user_name || (from_system ? AI_ASST : "Visitor")
          @user_nickname = @user_name == AI_ASST ? "AI" : @user_name.split.map(&:chr).join.upcase
        end

        def view_template
          div class: "pcb__user-identifier" do
            div(
              **classes(
                "pcb__user-identifier-avatar",
                from_system?: "pcb__user-identifier-avatar__bot",
                from_user?: "pcb__user-identifier-avatar__user",
              ),
            ) do
              @avatar || @user_nickname
            end
            span(class: "pcb__user-identifier-name") { @user_name }
          end
        end

        private

        def from_system? = !!@from_system

        def from_user? = !from_system?
      end
    end
  end
end
