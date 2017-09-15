require 'spec_helper'
require 'test_doubles'

describe ":expects macro" do
  context "when expected keys are in the context" do
    it "can access the keys as class methods" do
      resulting_context = TestDoubles::MakesTeaWithMilkAction.execute(
        :tea => "black",
        :milk => "full cream",
        :something => "else"
      )
      expect(resulting_context[:milk_tea]).to eq("black - full cream")
    end
  end

  context "when an expected key is not in the context" do
    it "raises an LightService::ExpectedKeysNotInContextError" do
      exception_msg = "expected :milk to be in the context during " \
                      "TestDoubles::MakesTeaWithMilkAction"
      expect do
        TestDoubles::MakesTeaWithMilkAction.execute(:tea => "black")
      end.to \
        raise_error(LightService::ExpectedKeysNotInContextError, exception_msg)
    end
  end

  context "when the `expects` macro is called multiple times" do
    it "can collect expected keys " do
      result = TestDoubles::MultipleExpectsAction.execute(
        :tea => "black",
        :milk => "full cream",
        :chocolate => "dark chocolate"
      )
      expect(result[:milk_tea]).to \
        eq("black - full cream - with dark chocolate")
    end
  end

  context "when an expected key is not used" do
    it "raises an LightService::ExpectedKeysNotUsedError" do
      exception_msg = "expected :milk to be used during " \
                      "TestDoubles::MakesTeaWithMilkAction"
      expect do
        TestDoubles::MakesTeaWithoutMilkAction.execute(
          :tea => "black",
          :milk => "full cream"
        )
      end.to \
        raise_error(LightService::ExpectedKeysNotUsedError, exception_msg)
    end
  end

  context "when a reserved key is listed as an expected key" do
    it "raises an error indicating a reserved key is expected" do
      exception_msg = "promised or expected keys cannot be a reserved key: " \
                      "[:message]"
      expect do
        TestDoubles::MakesTeaExpectingReservedKey.execute(:tea => "black",
                                                          :message => "no no")
      end.to \
        raise_error(LightService::ReservedKeysInContextError, exception_msg)
    end

    it "raises an error indicating that multiple reserved keys are expected" do
      exception_msg = "promised or expected keys cannot be a reserved key: " \
                      "[:message, :error_code, :current_action]"
      expect do
        TestDoubles::MakesTeaExpectingMultipleReservedKeys
          .execute(:tea => "black",
                   :message => "no no",
                   :error_code => 1,
                   :current_action => "update")
      end.to raise_error(LightService::ReservedKeysInContextError,
                         exception_msg)
    end
  end
end
