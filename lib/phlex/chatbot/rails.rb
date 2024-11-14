# require_relative "../chatbot"

module Phlex
  module Chatbot
    class Engine < ::Rails::Engine
      config.autoload_paths << "#{__dir__}/../../"

      initializer "phlex-chatbot.assets" do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.paths << File.expand_path("../../../dist", __dir__)
          app.config.assets.precompile += %w[
            bot.js
            bot.css
          ]
        end
      end

      # TODO: Test if this works without importmap gem
      initializer "phlex-chatbot.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.cache_sweepers << File.expand_path("../../../dist", __dir__)
        end
      end
    end
  end
end
