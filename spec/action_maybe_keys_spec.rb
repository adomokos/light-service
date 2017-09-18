require 'spec_helper'

describe ":maybe macro" do
  context "when the maybe macro is called multiple times" do
    it "marks all keys as maybe" do
      class MultipleMaybeAction
        extend LightService::Action
        expects :foo, :bar
        maybe :foo
        maybe :bar
      end

      expect(MultipleMaybeAction.maybe_keys).to eq [:foo, :bar]
    end
  end

  context "when the maybe macro is given a key that isn't expected" do
    it "raises an ArgumentError" do
      exception_msg = "Cannot mark unexpected keys [invalid, unknown] as maybe"
      expect do
        class InvalidAction
          extend LightService::Action
          maybe :invalid, :unknown
        end
      end.to raise_error(ArgumentError, exception_msg)
    end
  end
end
