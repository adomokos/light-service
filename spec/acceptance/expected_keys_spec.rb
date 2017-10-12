require 'spec_helper'

RSpec.describe "raises an error if expected keys are not used" do
  class ExpectedKeysAction
    extend LightService::Action
    expects :one, :two

    executed do |ctx|
      ctx.one * 2
    end
  end

  it "raises an error" do
    error_message = "Expected keys [:two] to be used during ExpectedKeysAction"
    expect { ExpectedKeysAction.execute(:one => 1, :two => 2) }.to(
      raise_error(LightService::ExpectedKeysNotUsedError, error_message)
    )
  end
end
