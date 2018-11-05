require 'spec_helper'

describe "Log from an organizer with a custom logger" do
  context "when overriding the global LightService organizer" do
    let(:global_logger_organizer) do
      Class.new do
        extend LightService::Organizer

        def self.call(number)
          with(:number => number).reduce(actions)
        end

        def self.actions
          [
            TestDoubles::AddsOneAction,
            TestDoubles::AddsTwoAction,
            TestDoubles::AddsThreeAction
          ]
        end
      end
    end

    let(:global_logger_string) { StringIO.new }

    let(:custom_logger_string) { StringIO.new }
    let(:custom_logger_organizer) do
      custom_logger = Logger.new(custom_logger_string)

      Class.new do
        extend LightService::Organizer
        log_with custom_logger

        def self.call(coffee, this_hot = :very_hot)
          with(:milk => this_hot, :coffee => coffee)
            .reduce(TestDoubles::MakesLatteAction,
                    TestDoubles::AddsTwoActionWithFetch)
        end
      end
    end

    before do
      @original_global_logger = LightService::Configuration.logger
      LightService::Configuration.logger = Logger.new(global_logger_string)
    end

    it "logs in own logger" do
      global_logger_organizer.call(1)
      custom_logger_organizer.call(:coffee => "Cappucino")

      expect(custom_logger_string.string).to include("MakesLatteAction")
      expect(custom_logger_string.string).to_not include("AddsOneAction")
      expect(global_logger_string.string).to include("AddsOneAction")
      expect(global_logger_string.string).to_not include("MakesLatteAction")
    end

    after do
      LightService::Configuration.logger = @original_global_logger
    end
  end
end
