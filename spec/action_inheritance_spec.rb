require 'spec_helper'
require 'test_doubles'

describe LightService::Action do
  describe "when an Action is subclassed" do
    class MakesTeaWithMilkSubclass < TestDoubles::MakesTeaWithMilkAction
    end

    class ActionWithTotallyDifferentKeys
      extend LightService::Action

      expects :no_one_else_expects_this
      promises :no_one_else_promises_this
    end

    it "subclass inherits expected and promised keys" do
      expect(MakesTeaWithMilkSubclass.expected_keys).
        to match_array(TestDoubles::MakesTeaWithMilkAction.expected_keys)

      expect(MakesTeaWithMilkSubclass.promised_keys).
        to match_array(TestDoubles::MakesTeaWithMilkAction.promised_keys)
    end

    it "subclass behaves like its parent" do
      subclass_result = MakesTeaWithMilkSubclass.execute(tea: "tea", milk: "milk")
      parent_result = TestDoubles::MakesTeaWithMilkAction.execute(tea: "tea", milk: "milk")

      expect(subclass_result).to eq(parent_result)
    end

    it "expected and promised keys are not mixed with other (non-subclass) Actions" do
      expect(
        MakesTeaWithMilkSubclass.expected_keys &
        ActionWithTotallyDifferentKeys.expected_keys
      ).to eq([])

      expect(
        MakesTeaWithMilkSubclass.promised_keys &
        ActionWithTotallyDifferentKeys.promised_keys
      ).to eq([])
    end
  end
end
