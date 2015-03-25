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
      exception_error_text = "expected :milk to be in the context during TestDoubles::MakesTeaWithMilkAction"
      expect {
        TestDoubles::MakesTeaWithMilkAction.execute(:tea => "black")
      }.to raise_error(LightService::ExpectedKeysNotInContextError, exception_error_text)
    end
  end

  it "can collect expected keys when the `expects` macro is called multiple times" do
    resulting_context = TestDoubles::MultipleExpectsAction.execute(
      :tea => "black",
      :milk => "full cream",
      :chocolate => "dark chocolate"
    )
    expect(resulting_context[:milk_tea]).to eq("black - full cream - with dark chocolate")
  end

  context "when a reserved key is listed as an expected key" do
    it "raises an error indicating a reserved key is expected" do
      exception_error_text = "promised or expected keys cannot be a reserved key: [:message]"
      expect {
        TestDoubles::MakesTeaExpectingReservedKey.execute(:tea => "black", :message => "no no")
      }.to raise_error(LightService::ReservedKeysInContextError, exception_error_text)
    end

    it "raises an error indicating that multiple reserved keys are expected" do
      exception_error_text = "promised or expected keys cannot be a reserved key: [:message, :error_code, :current_action]"
      expect {
        TestDoubles::MakesTeaExpectingMultipleReservedKeys.execute(:tea => "black", :message => "no no", :error_code => 1, :current_action => "update")
      }.to raise_error(LightService::ReservedKeysInContextError, exception_error_text)
    end
  end
end
