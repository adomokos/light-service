require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestReduce
    extend LightService::Orchestrator

    def self.run(context, steps)
      with(context).reduce(steps)
    end
  end

  it 'responds to both actions and organizers' do
    result = TestReduce.run({ :number => 0 }, [
      TestDoubles::AddTwoOrganizer,
      TestDoubles::AddOneAction
    ])

    expect(result).to be_success
    expect(result.number).to eq(3)
  end

  it 'fails fast by skipping proceeding actions/organizers after failure' do
    result = TestReduce.run({ :number => 0 }, [
      TestDoubles::AddTwoOrganizer,
      TestDoubles::FailureAction,
      TestDoubles::AddOneAction
    ])

    expect(result).not_to be_success
    expect(result.number).to eq(2)
  end

  it 'does not allow anything but actions and organizers' do
    expect do
      TestReduce.run({}, [double])
    end.to raise_error(RuntimeError)
  end
end
