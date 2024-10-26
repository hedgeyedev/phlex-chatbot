# frozen_string_literal: true

module Phlex
  module Chatbot
    class Contextualizer
      attr_reader :system_avatar, :system_name, :user_avatar, :user_name

      def self.create(_channel_id)
        new
      end

      def initialize(system_name: "AI Assistant", system_avatar: nil, user_name: "Visitor", user_avatar: nil, &blk)
        @system_name   = system_name
        @system_avatar = system_avatar
        @user_name     = user_name
        @user_avatar   = user_avatar
        @callback      = blk
      end

      def contextualize(hash)
        if hash[:from_user]
          hash.merge(user_name: user_name, avatar: user_avatar)
        else
          hash.merge(user_name: system_name, avatar: system_avatar)
        end
      end

      def call(bot, data, channel_id)
        @callback.call(bot, data, channel_id)
      end
    end
  end
end
