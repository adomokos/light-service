require 'spec_helper'
require 'test_doubles'

describe ":expects macro using defaults" do
  context "when all expected keys are supplied" do
    it "is expected to ignore default values" do
      outcome = TestDoubles::AddsNumbersWithOptionalDefaults.execute(
        :first_number => 3,
        :second_number => 5,
        :third_number => 7
      )

      expect(outcome.total).to eq 15
    end
  end

  context "when defaults are supplied" do
    it "is expected to use static values" do
      outcome = TestDoubles::AddsNumbersWithOptionalDefaults.execute(
        :first_number => 3,
        :second_number => 7
      )

      expect(outcome.total).to eq 20
    end

    it "is expected to use dynamic values" do
      outcome = TestDoubles::AddsNumbersWithOptionalDefaults.execute(
        :first_number => 3,
        :third_number => 5
      )

      expect(outcome.total).to eq 18
    end

    it "is expected to process defaults in their defined order" do
      outcome = TestDoubles::AddsNumbersWithOptionalDefaults.execute(
        :third_number => 5,
        :first_number => 3
      )

      expect(outcome.total).to eq 18
    end

    it "is expected to use all defaults if required" do
      outcome = TestDoubles::AddsNumbersWithOptionalDefaults.execute(
        :first_number => 3
      )

      expect(outcome.total).to eq 23
    end
  end
end
