require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestWithCallback
    extend LightService::Orchestrator

    def self.run(context = {})
      with(context).reduce(steps)
    end

    def self.steps
      [
        SetUpContextAction,
        with_callback(IterateCollectionAction,
                      [IncrementCountAction,
                       AddToTotalAction])
      ]
    end
  end

  class SetUpContextAction
    extend LightService::Action
    promises :numbers, :counter, :total

    executed do |ctx|
      ctx.numbers = [1, 2, 3]
      ctx.counter = 0
      ctx.total = 0
    end
  end

  class IterateCollectionAction
    extend LightService::Action
    expects :numbers, :callback
    promises :number

    executed do |ctx|
      ctx.numbers.each do |number|
        ctx.number = number
        ctx.callback.call(ctx)
      end
    end
  end

  class IncrementCountAction
    extend LightService::Action
    expects :counter

    executed do |ctx|
      ctx.counter = ctx.counter + 1
    end
  end

  class AddToTotalAction
    extend LightService::Action
    expects :number, :total

    executed do |ctx|
      ctx.total += ctx.number
    end
  end

  it 'calls the actions defined with callback' do
    result = TestWithCallback.run

    expect(result.counter).to eq(3)
    expect(result.total).to eq(6)
  end
end
