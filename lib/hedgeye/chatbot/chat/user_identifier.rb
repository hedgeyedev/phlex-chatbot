# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class UserIdentifier < Phlex::HTML
        AI_ASST = "AI Assistant"

        def initialize(user_name: nil, from_system: false)
          @from_system   = from_system
          @user_name     = user_name || (from_system ? AI_ASST : "Visitor")
          @user_nickname = user_name == AI_ASST ? "AI" : user_name.split.map(&:chr).join.upcase
        end

        def view_template
          div class: "hcb__user-identifier" do
            div(**classes("hcb__user-identifier-avatar", from_system?: "hcb__user-identifier-avatar__bot", from_user?: "hcb__user-identifier-avatar__user")) do
              @user_nickname
            end
            span(class: "hcb__user-identifier-name") { @user_name }
          end
        end

        private

        def from_system? = !!@from_system

        def from_user? = !from_system?
      end
    end
  end
end
