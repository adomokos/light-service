require 'spec_helper'

module LightService
  describe ":promises macro" do
    class DummyActionForKeysToPromise
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea, :something_else

      executed do |context|
        context[:some_tea] = "#{context.tea} - #{context.milk}"
      end
    end

    context "when the promised key is not in the context" do
      it "raises an ArgumentError" do
        exception_error_text = "promised :milk_tea, :something_else to be in the context during LightService::DummyActionForKeysToPromise"
        expect {
          DummyActionForKeysToPromise.execute(:tea => "black", :milk => "full cream")
        }.to raise_error(PromisedKeysNotInContextError, exception_error_text)
      end
    end

    context "when the promised key is in the context" do
      class DummyActionSetsItemInContext
        include LightService::Action
        expects :tea, :milk
        promises :milk_tea

        executed do |context|
          context.milk_tea = "#{context.tea} - #{context.milk}"
          context.milk_tea += " hello"
        end
      end
      it "sets in the context if it was set with not nil" do
        result_context = DummyActionSetsItemInContext.execute(:tea => "black",
                                                              :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to eq("black - full cream hello")
      end

      class DummyActionNilNotSetInContext
        include LightService::Action
        expects :tea, :milk
        promises :milk_tea

        executed do |context|
          context.milk_tea = nil
        end
      end
      it "sets in the context if it was set with nil" do
        result_context = DummyActionNilNotSetInContext.execute(:tea => "black",
                                                              :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to be_nil
      end

    end
  end
end
