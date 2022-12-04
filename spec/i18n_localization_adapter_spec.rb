require "spec_helper"
require 'test_doubles'

describe LightService::I18n::LocalizationAdapter do
  let(:action_class) { TestDoubles::AnAction }
  let(:adapter) { described_class.new }

  describe "#failure" do
    subject { adapter.failure(message_or_key, action_class) }

    context "when provided a Symbol" do
      let(:message_or_key) { :not_found }

      it "translates the message" do
        expected_scope = "test_doubles/an_action.light_service.failures"

        expect(I18n).to receive(:t)
          .with(message_or_key, :scope => expected_scope)
          .and_return("message")

        expect(subject).to eq("message")
      end

      it "allows passing interpolation options to I18n layer" do
        expect(I18n).to receive(:t)
          .with(message_or_key, hash_including(:i18n_variable => "value"))
          .and_return("message")

        subject = adapter.failure(message_or_key,
                                  action_class,
                                  :i18n_variable => "value")

        expect(subject).to eq("message")
      end
    end

    context "when provided a String" do
      let(:message_or_key) { "action failed" }

      it "returns the message" do
        expect(subject).to eq(message_or_key)
      end
    end
  end

  describe "#success" do
    subject { adapter.success(message_or_key, action_class) }

    context "when provided a Symbol" do
      let(:message_or_key) { :not_found }

      it "translates the message" do
        expected_scope = "test_doubles/an_action.light_service.successes"

        expect(I18n).to receive(:t)
          .with(message_or_key, :scope => expected_scope)
          .and_return("message")

        expect(subject).to eq("message")
      end

      it "allows passing interpolation options to I18n layer" do
        expect(I18n).to receive(:t)
          .with(message_or_key, hash_including(:i18n_variable => "value"))
          .and_return("message")

        subject = adapter.success(message_or_key,
                                  action_class,
                                  :i18n_variable => "value")

        expect(subject).to eq("message")
      end
    end

    context "when provided a String" do
      let(:message_or_key) { "action failed" }

      it "returns the message" do
        expect(subject).to eq(message_or_key)
      end
    end
  end
end
