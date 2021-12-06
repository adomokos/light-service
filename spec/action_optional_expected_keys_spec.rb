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

    it "is expected to assign multiple defaults if configured to do so" do
      outcome = TestDoubles::AddsNumbersWithMultipleDefaults.execute

      expect(outcome.total).to eq 30
    end

    it "is expected to assign multiple defaults but not override the context" do
      outcome = TestDoubles::AddsNumbersWithMultipleDefaults.execute(:first_number => 15)

      expect(outcome.total).to eq 35
    end
  end

  context "when used within an organizer" do
    it "is expected to process required defaults" do
      outcome = TestDoubles::OrganizerWithActionsUsingDefaults.call

      expect(outcome.total).to eq 20
    end
  end

  context "when defaults are misconfigured" do
    it "is expected to raise an exception" do
      expect do
        # Needs to be specified in the block
        # as error is raised at define time
        class AddsNumbersWithIncorrectDefaults
          extend LightService::Action

          expects  :first,  :default => 10 # This one is fine. Other two arent
          expects  :second, :defalut => ->(ctx) { ctx[:first] + 7 }
          expects  :third,  :deafult => 10
          promises :total

          executed do |ctx|
            ctx.total = ctx.first + ctx.second + ctx.third
          end
        end
      end.to raise_error(LightService::InvalidExpectOptionError)
    end
  end
end
