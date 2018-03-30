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
                               TestDoubles::AddsOneAction)
                ])
    end
  end

  class TestSkipAfter
    extend LightService::Organizer
    def self.call
      with(:number => 1)
        .reduce([
                  TestDoubles::AddsOneAction,
                  reduce_until(->(ctx) { ctx.number == 3 }, [
                                 TestDoubles::AddsOneAction
                               ]),
                  TestDoubles::SkipAllAction,
                  TestDoubles::AddsOneAction
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
                               TestDoubles::AddsOneAction),
                  TestDoubles::AddsOneAction
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
