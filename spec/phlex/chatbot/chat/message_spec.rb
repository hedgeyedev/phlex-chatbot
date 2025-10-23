# frozen_string_literal: true

require "spec_helper"

RSpec.describe Phlex::Chatbot::Chat::Message do
  include_context "for phlex views"

  let(:args) do
    {
      message: message,
      user_name: "Test User",
      from_user: from_user,
    }
  end

  let(:from_user) { true }

  describe "XSS protection" do
    context "with dangerous HTML" do
      let(:message) { "<script>alert('XSS')</script>" }

      it "escapes HTML by default" do
        expect(rendered.to_s).not_to include("<script>")
      end
    end

    context "with plain text" do
      let(:message) { "Hello, this is a normal message" }

      it "renders text normally" do
        expect(rendered.to_s).to include("Hello, this is a normal message")
      end
    end

    context "for bot messages" do
      let(:from_user) { false }
      let(:message) { "<script>alert('XSS')</script>" }

      it "also escapes HTML by default" do
        expect(rendered.to_s).not_to include("<script>")
      end
    end
  end

  describe "message rendering" do
    let(:message) { "Test message" }

    it "applies correct CSS class based on from_user" do
      expect(rendered.to_s).to include("pcb__message__user")
    end

    it "renders the user name" do
      expect(rendered.to_s).to include("Test User")
    end
  end
end
