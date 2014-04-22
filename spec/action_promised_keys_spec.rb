require 'spec_helper'

module LightService
  describe ":expects macro" do
    class DummyActionForKeysToPromise
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea

      executed do |context|
        context[:some_tea] = "#{self.tea} - #{self.milk}"
      end
    end

    describe ".promises_keys" do
      it "returns the keys it promises to set in the context" do
        expect(DummyActionForKeysToPromise.promised_keys).to eq [:milk_tea]
      end
    end
  end
end
