require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceUntil
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce(actions)
    end

    def self.actions
      [
        reduce_until(->(ctx) { ctx.number == 3 },
                     TestDoubles::AddOneAction)
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces until the block evaluates to true' do
    context = { :number => 1 }
    result = TestReduceUntil.call(context)

    expect(result).to be_success
    expect(result.number).to eq(3)
  end

  it 'does not execute on failed context' do
    empty_context.fail!('Something bad happened')

    result = TestReduceUntil.call(empty_context)
    expect(result).to be_failure
  end

  it 'does not execute a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestReduceUntil.call(empty_context)
    expect(result).to be_success
  end
end
