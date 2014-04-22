require 'spec_helper'

module LightService
  describe ":promises macro" do
    class DummyActionForKeysToPromise
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea

      executed do |context|
        context[:some_tea] = "#{self.tea} - #{self.milk}"
      end
    end

    context "when the promised key is not in the context" do
      it "raises an ArgumentError" do
        expect {
          DummyActionForKeysToPromise.execute(:tea => "black", :milk => "full cream")
        }.to raise_error(PromisedKeysNotInContextError, "promised :[:milk_tea] to be in the context")
      end
    end
  end
end
