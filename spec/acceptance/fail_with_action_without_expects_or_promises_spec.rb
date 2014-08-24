require 'spec_helper'
require 'test_doubles'

describe "Action fails without expects or promises" do
  context "when an action in the series of actions does not have expects and promises" do
    it "fails with NoExpectsOrPromisesFoundOnActionError" do
      exception_error_text = "No expected or promised keys were found in the following actions: TestDoubles::AddsTwoAction"
      expect {
        TestDoubles::FailsWithNoExpectsOrPromisesFoundOnActionError.call("espresso") }.to \
      raise_error(LightService::NoExpectsOrPromisesFoundOnActionError, exception_error_text)
    end
  end
end
