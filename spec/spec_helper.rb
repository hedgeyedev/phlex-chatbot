# frozen_string_literal: true

require "phlex/chatbot"
require "phlex/testing/nokogiri"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_context "for phlex views" do
  include Phlex::Testing::Nokogiri::FragmentHelper

  subject(:rendered) { render(component) }

  let(:args)       { {} }
  let(:component)  { described_class.new(**args) }
end
