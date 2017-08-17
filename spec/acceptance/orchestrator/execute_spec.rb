require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestExecute
    extend LightService::Orchestrator

    def self.run(context)
      with(context).reduce(steps)
    end

    def self.steps
      [
        TestDoubles::AddOneAction,
        execute(->(ctx) { ctx.number += 1 }),
        execute(->(ctx) { ctx[:something] = 'hello' }),
        TestDoubles::AddOneAction
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'calls the lambda in the execute block using the context' do
    result = TestExecute.run(:number => 0)

    expect(result).to be_success
    expect(result.number).to eq(3)
    expect(result[:something]).to eq('hello')
  end

  it 'will not execute a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestExecute.run(empty_context)

    expect(result).to be_failure
  end

  it 'does not execute over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestExecute.run(empty_context)
    expect(result).to be_success
  end
end
