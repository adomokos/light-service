require 'spec_helper'

module LightService
  describe ":expects macro" do
    class DummyActionForKeysToExpect
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea

      executed do |context|
        context.milk_tea = "#{context.tea} - #{context.milk}"
      end
    end

    context "when expected keys are in the context" do
      it "can access the keys as class methods" do
        resulting_context = DummyActionForKeysToExpect.execute(
          :tea => "black",
          :milk => "full cream",
          :something => "else"
        )
        expect(resulting_context[:milk_tea]).to eq("black - full cream")
      end
    end

    context "when expected keys are not in the context" do
      it "raises an error" do
        exception_error_text = "expected :milk to be in the context during LightService::DummyActionForKeysToExpect"
        expect {
          DummyActionForKeysToExpect.execute(:tea => "black")
        }.to raise_error(ExpectedKeysNotInContextError, exception_error_text)
      end
    end
  end
end
