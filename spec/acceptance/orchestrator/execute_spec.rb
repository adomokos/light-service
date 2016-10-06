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
        TestDoubles::AddOneAction
      ]
    end
  end

  it 'calls the lambda in the execute block using the context' do
    result = TestExecute.run(:number => 0)

    expect(result).to be_success
    expect(result.number).to eq(3)
  end
end
