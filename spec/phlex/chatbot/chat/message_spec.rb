# frozen_string_literal: true

require "spec_helper"

RSpec.describe Phlex::Chatbot::Chat::Message do
  include_context "for phlex views"

  let(:args) do
    {
      message: message,
      user_name: "Test User",
      from_user: from_user
    }
  end

  let(:from_user) { true }

  describe "XSS protection" do
    context "when message contains script tags" do
      let(:message) { "<script>alert('XSS')</script>" }

      it "escapes the script tags" do
        expect(rendered.to_s).not_to include("<script>")
        expect(rendered.to_s).to include("&lt;script&gt;")
      end

      it "renders the escaped content" do
        # Verify script tags are escaped (allowing different quote escape formats)
        expect(rendered.to_s).to match(/&lt;script&gt;alert\(['&#39;]+XSS['&#39;]+\)&lt;\/script&gt;/)
      end
    end

    context "when message contains image with onerror" do
      let(:message) { '<img src=x onerror="alert(1)">' }

      it "escapes the HTML" do
        expect(rendered.to_s).not_to include('<img src=x onerror')
        expect(rendered.to_s).to include("&lt;img")
      end
    end

    context "when message contains iframe" do
      let(:message) { '<iframe src="evil.com"></iframe>' }

      it "escapes the iframe" do
        expect(rendered.to_s).not_to include("<iframe")
        expect(rendered.to_s).to include("&lt;iframe")
      end
    end

    context "when message contains onclick handler" do
      let(:message) { '<div onclick="alert(1)">Click me</div>' }

      it "escapes the HTML and onclick handler" do
        # The entire HTML tag should be escaped, preventing onclick execution
        expect(rendered.to_s).to include("&lt;div")
        expect(rendered.to_s).to include("&gt;Click me&lt;/div&gt;")
      end
    end

    context "when message is plain text" do
      let(:message) { "Hello, this is a normal message" }

      it "renders the text normally" do
        expect(rendered.to_s).to include("Hello, this is a normal message")
      end
    end

    context "when message contains ampersands and quotes" do
      let(:message) { 'I said "hello" & you said "goodbye"' }

      it "properly escapes special characters" do
        # Ampersands should be escaped, quotes may use various escape formats
        expect(rendered.to_s).to include("&amp;")
        expect(rendered.to_s).to include("hello")
        expect(rendered.to_s).to include("goodbye")
      end
    end

    context "when message is for bot (from_user: false)" do
      let(:from_user) { false }
      let(:message) { "<script>alert('XSS')</script>" }

      it "also escapes HTML by default" do
        expect(rendered.to_s).not_to include("<script>")
        expect(rendered.to_s).to include("&lt;script&gt;")
      end
    end
  end

  describe "message rendering" do
    let(:message) { "Test message" }

    context "when from_user is true" do
      let(:from_user) { true }

      it "applies user message class" do
        expect(rendered.to_s).to include("pcb__message__user")
      end
    end

    context "when from_user is false" do
      let(:from_user) { false }

      it "applies bot message class" do
        expect(rendered.to_s).to include("pcb__message__bot")
      end
    end

    context "when user_name is provided" do
      it "renders the user name" do
        expect(rendered.to_s).to include("Test User")
      end
    end
  end
end
