require 'spec_helper'

RSpec.describe "fail_and_return!" do
  describe "returns immediately from executed block" do
    class FailAndReturnAction
      extend LightService::Action
      promises :one, :two

      executed do |ctx|
        ctx.one = 1
        # Have to set it in Context
        ctx.two = nil

        ctx.fail_and_return!('Something went wrong')
        ctx.two = 2
      end
    end

    it "returns immediately from executed block" do
      result = FailAndReturnAction.execute

      expect(result).to be_failure
      expect(result.two).to be_nil
    end
  end
end
