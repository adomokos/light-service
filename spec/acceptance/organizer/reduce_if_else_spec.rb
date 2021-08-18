require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceIfElse
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce(actions)
    end

    def self.actions
      [
        TestDoubles::AddsOneAction,
        reduce_if_else(
          ->(ctx) { ctx.number == 1 },
          [TestDoubles::AddsOneAction],
          [TestDoubles::AddsTwoAction]
        )
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces the if_steps if the condition is true' do
    result = TestReduceIfElse.call(:number => 0)

    expect(result).to be_success
    expect(result[:number]).to eq(2)
  end

  it 'reduces the else_steps if the condition is false' do
    result = TestReduceIfElse.call(:number => 2)

    expect(result).to be_success
    expect(result[:number]).to eq(5)
  end

  it 'will not reduce over a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestReduceIfElse.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not reduce over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestReduceIfElse.call(empty_context)
    expect(result).to be_success
  end

  it "knows that it's being conditionally reduced from within an organizer" do
    result = TestReduceIfElse.call(:number => 2)

    expect(result.organized_by).to eq TestReduceIfElse
  end
end
