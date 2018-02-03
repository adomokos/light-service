require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestSkipBefore
    extend LightService::Organizer
    def self.call
      with(:number => 1)
        .reduce([
                  TestDoubles::SkipAllAction,
                  reduce_until(->(ctx) { ctx.number == 3 },
                               TestDoubles::AddOneAction)
                ])
    end
  end

  class TestSkipAfter
    extend LightService::Organizer
    def self.call
      with(:number => 1)
        .reduce([
                  TestDoubles::AddOneAction,
                  reduce_until(->(ctx) { ctx.number == 3 }, [
                                 TestDoubles::AddOneAction
                               ]),
                  TestDoubles::SkipAllAction,
                  TestDoubles::AddOneAction
                ])
    end
  end

  class TestContextFailure
    extend LightService::Organizer
    def self.call
      with(:number => 1)
        .reduce([
                  TestDoubles::FailureAction,
                  reduce_until(->(ctx) { ctx[:number] == 3 },
                               TestDoubles::AddOneAction),
                  TestDoubles::AddOneAction
                ])
    end
  end

  it 'skips all the rest of the actions' do
    result = TestSkipBefore.call

    expect(result).to be_success
    expect(result[:number]).to eq(1)
  end

  it 'skips after an action in nested context' do
    result = TestSkipAfter.call

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'respects failure across all nestings' do
    result = TestContextFailure.call

    expect(result).to be_failure
    expect(result[:number]).to eq(1)
  end
end
