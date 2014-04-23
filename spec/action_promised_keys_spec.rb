require 'spec_helper'

module LightService
  describe ":promises macro" do
    class DummyActionForKeysToPromise
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea, :something_else

      executed do |context|
        context[:some_tea] = "#{self.tea} - #{self.milk}"
      end
    end

    context "when the promised key is not in the context" do
      it "raises an ArgumentError" do
        exception_error_text = "promised :milk_tea, :something_else to be in the context"
        expect {
          DummyActionForKeysToPromise.execute(:tea => "black", :milk => "full cream")
        }.to raise_error(PromisedKeysNotInContextError, exception_error_text)
      end
    end
  end
end
