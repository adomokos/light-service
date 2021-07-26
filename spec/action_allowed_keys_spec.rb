require 'spec_helper'
require 'test_doubles'

describe ":allows macro" do
  context "when allowed keys are passed in" do
    it "uses the passed value" do
      resulting_context = TestDoubles::AddsArgumentOrTwo.execute(
        counter: 10,
        increment: 5
      )
      expect(resulting_context[:result]).to eq(15)
    end
  end

  context "when allowed keys are not passed in" do
    it "uses the default value" do
      resulting_context = TestDoubles::AddsArgumentOrTwo.execute(
        counter: 10
      )
      expect(resulting_context[:result]).to eq(12)
    end
  end
end
