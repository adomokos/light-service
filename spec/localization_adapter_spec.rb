require "spec_helper"
require 'test_doubles'

describe LightService::LocalizationAdapter do
  let(:action_class) { TestDoubles::AnAction }
  let(:adapter) { described_class.new }

  before do
    LightService::LocalizationMap.instance[:en] = {
      :'test_doubles/an_action' => {
        :light_service => {
          :failures => {
            :not_found => "failure message"
          },
          :successes => {
            :not_found => "success message"
          }
        }
      }
    }
  end

  describe "#failure" do
    subject { adapter.failure(message_or_key, action_class) }

    context "when provided a Symbol" do
      let(:message_or_key) { :not_found }

      it "translates the message" do
        expect(subject).to eq("failure message")
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
        expect(subject).to eq("success message")
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
