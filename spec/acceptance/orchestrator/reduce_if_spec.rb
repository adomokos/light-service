require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestReduceIf
    extend LightService::Orchestrator

    def self.run(context)
      with(context).reduce([
                             TestDoubles::AddOneAction,
                             reduce_if(->(ctx) { ctx.number == 1 }, [
                                         TestDoubles::AddOneAction
                                       ])
                           ])
    end
  end

  it 'reduces if the block evaluates to true' do
    result = TestReduceIf.run(:number => 0)

    expect(result).to be_success
    expect(result.number).to eq(2)
  end

  it 'does not reduce if the block evaluates to false' do
    result = TestReduceIf.run(:number => 2)

    expect(result).to be_success
    expect(result.number).to eq(3)
  end
end
