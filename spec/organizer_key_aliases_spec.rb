require 'spec_helper'
require 'test_doubles'

describe "organizer aliases macro" do
  let(:organizer_with_alias) do
    Class.new do
      extend LightService::Organizer

      aliases :promised_key => :expected_key

      def self.call(ctx = {})
        with(ctx).reduce(
          [
            TestDoubles::PromisesPromisedKeyAction,
            TestDoubles::ExpectsExpectedKeyAction
          ]
        )
      end
    end
  end

  context "when aliases is invoked" do
    it "makes aliases available to the actions" do
      result = organizer_with_alias.call
      expect(result[:expected_key]).to eq(result[:promised_key])
      expect(result.expected_key).to eq(result[:promised_key])
    end
  end
end
