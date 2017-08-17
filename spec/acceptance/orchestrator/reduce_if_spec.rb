require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestReduceIf
    extend LightService::Orchestrator

    def self.run(context)
      with(context).reduce(steps)
    end

    def self.steps
      [
        TestDoubles::AddOneAction,
        reduce_if(->(ctx) { ctx.number == 1 },
                  TestDoubles::AddOneAction)
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces if the block evaluates to true' do
    result = TestReduceIf.run(:number => 0)

    expect(result).to be_success
    expect(result[:number]).to eq(2)
  end

  it 'does not reduce if the block evaluates to false' do
    result = TestReduceIf.run(:number => 2)

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'will not reduce over a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestReduceIf.run(empty_context)

    expect(result).to be_failure
  end

  it 'does not reduce over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestReduceIf.run(empty_context)
    expect(result).to be_success
  end
end
