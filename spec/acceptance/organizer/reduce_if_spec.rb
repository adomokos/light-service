require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceIf
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce(actions)
    end

    def self.actions
      [
        TestDoubles::AddsOneAction,
        reduce_if(->(ctx) { ctx.number == 1 },
                  TestDoubles::AddsOneAction)
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces if the block evaluates to true' do
    result = TestReduceIf.call(:number => 0)

    expect(result).to be_success
    expect(result[:number]).to eq(2)
  end

  it 'does not reduce if the block evaluates to false' do
    result = TestReduceIf.call(:number => 2)

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'will not reduce over a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestReduceIf.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not reduce over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestReduceIf.call(empty_context)
    expect(result).to be_success
  end

  it 'skips actions within in its own scope' do
    org = Class.new do
      extend LightService::Organizer

      def self.call
        reduce(actions)
      end

      def self.actions
        [
          reduce_if(
            ->(c) { !c.nil? },
            [
              execute(->(c) { c[:first_reduce_if] = true }),
              execute(->(c) { c.skip_remaining! }),
              execute(->(c) { c[:second_reduce_if] = true })
            ]
          ),
          execute(->(c) { c[:last_outside] = true })
        ]
      end
    end

    result = org.call

    aggregate_failures do
      expect(result[:first_reduce_if]).to be true
      expect(result[:second_reduce_if]).to be_nil
      expect(result[:last_outside]).to be true
    end
  end
end
