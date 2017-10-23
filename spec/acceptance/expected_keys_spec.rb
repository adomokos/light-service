require 'spec_helper'

RSpec.describe "verifying expected keys are used" do
  class OnlyExpectedKeysAction
    extend LightService::Action
    expects :one, :two

    executed do |ctx|
      ctx.one * 2
    end
  end

  class OnlyMaybeKeysAction
    extend LightService::Action
    expects :maybe => [:one, :two]

    executed do |ctx|
      ctx.one * 2
    end
  end

  class SomeMaybeKeysAction
    extend LightService::Action
    expects :one, :maybe => :two

    executed do |ctx|
      ctx.one * 2
    end
  end

  class UsesMaybeKeysAction
    extend LightService::Action
    expects :one, :maybe => :two
    promises :product

    executed do |ctx|
      ctx.product = ctx.one * ctx.two
    end
  end

  it "raises an error when expected keys aren't used" do
    error_message = "Expected keys [:two] to be used during "\
                    "OnlyExpectedKeysAction"
    expect do
      OnlyExpectedKeysAction.execute(:one => 1, :two => 2)
    end.to(raise_error(LightService::ExpectedKeysNotUsedError, error_message))
  end

  it "doesn't raise an error if maybe keys aren't used" do
    expect do
      OnlyMaybeKeysAction.execute(:one => 1, :two => 2)
    end.not_to(raise_error)
    expect do
      SomeMaybeKeysAction.execute(:one => 1, :two => 2)
    end.not_to(raise_error)
  end

  it "accesses maybe keys like normal expects keys" do
    result = UsesMaybeKeysAction.execute(:one => 8, :two => 11)
    expect(result.product).to eq 88
  end
end
