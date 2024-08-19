# frozen_string_literal: true

require_relative "lib/phlex/chatbot/version"

Gem::Specification.new do |spec|
  spec.name = "phlex-chatbot"
  spec.version = Phlex::Chatbot::VERSION
  spec.authors = ["Hedgeye Risk Management, LLC"]
  spec.email = ["developers@hedgeye.com"]

  spec.summary = "summarize it"
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/hedgeyedev/phlex-chatbot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata["github_repo"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `bin/build`
    Dir["{dist,lib}/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.3"
  spec.add_dependency "phlex", "~> 1.10"
  spec.add_dependency "rack", "~> 3.1"
  spec.add_dependency "actioncable", "~> 7.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
