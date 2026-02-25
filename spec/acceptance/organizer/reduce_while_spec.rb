require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceWhile
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce(actions)
    end

    def self.actions
      [
        reduce_while(->(ctx) { ctx[:number] < 3 }, [
                       TestDoubles::AddsOneAction,
                       TestDoubles::AddsTwoAction
                     ])
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces while the block evaluates to true' do
    result = TestReduceWhile.call(:number => 0)

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'checks the condition before each action' do
    result = TestReduceWhile.call(:number => 2)

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'does not execute any steps when the condition is false from the start' do
    result = TestReduceWhile.call(:number => 5)

    expect(result).to be_success
    expect(result[:number]).to eq(5)
  end

  it 'does not execute on failed context' do
    empty_context.fail!('Something bad happened')

    result = TestReduceWhile.call(empty_context)
    expect(result).to be_failure
  end

  it 'does not execute a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestReduceWhile.call(empty_context)
    expect(result).to be_success
  end

  it "is expected to know its organizer when reducing while a condition" do
    result = TestReduceWhile.call(:number => 0)

    expect(result.organized_by).to eq TestReduceWhile
  end

  it 'skips actions within its own scope' do
    org = Class.new do
      extend LightService::Organizer

      def self.call
        reduce(actions)
      end

      def self.actions
        [
          reduce_while(
            ->(c) { !c.nil? },
            [
              execute(->(c) { c[:first_reduce_while] = true }),
              execute(&:skip_remaining!),
              execute(->(c) { c[:second_reduce_while] = true })
            ]
          ),
          execute(->(c) { c[:last_outside] = true })
        ]
      end
    end

    result = org.call

    aggregate_failures do
      expect(result[:first_reduce_while]).to be true
      expect(result[:second_reduce_while]).to be true
      expect(result[:last_outside]).to be true
    end
  end
end
