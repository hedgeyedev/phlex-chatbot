# frozen_string_literal: true

module Hedgeye
  module Chatbot
    module Chat
      class UserIdentifierTemplate < Phlex::HTML
        def initialize(user_name: nil, from_system: false)
          @from_system   = from_system
          @user_name     = user_name || "Visitor"
          @user_nickname = user_name.split.map(&:chr).join.upcase
        end

        def view_template
          template_tag(id: "hcb-user-identifier") do
            render UserIdentifier.new(user_name: @user_name, from_system: @from_system)
          end
        end
      end
    end
  end
end
