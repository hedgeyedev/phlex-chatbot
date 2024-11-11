require_relative "../chatbot"

module Phlex
  module Chatbot
    # class Railtie < ::Rails::Engine
    # end

    class Engine < ::Rails::Engine
      config.autoload_paths << "#{__dir__}/../"
      initializer "phlex-chatbot.assets" do
        if ::Rails.application.config.respond_to?(:assets)
          ::Rails.application.config.assets.paths << File.expand_path("../../../dist", __dir__)
          ::Rails.application.config.assets.precompile += %w[
            bot.js
            bot.css
          ]
        end
      end
    end
  end
end
