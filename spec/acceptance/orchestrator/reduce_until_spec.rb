require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Orchestrator do
  class TestReduceUntil
    extend LightService::Orchestrator

    def self.run
      with(:number => 1).reduce(steps)
    end

    def self.steps
      [
        reduce_until(->(ctx) { ctx.number == 3 },
                     TestDoubles::AddOneAction)
      ]
    end
  end

  it 'reduces until the block evaluates to true' do
    result = TestReduceUntil.run

    expect(result).to be_success
    expect(result.number).to eq(3)
  end
end
