require 'spec_helper'

module IterateSpec
  class AddsOneWithRollbackAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      context.number += 1
    end

    rolled_back do |context|
      context.number -= 1
    end
  end

  class AddsOneWithRollbackSelfConsciousAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      raise unless context.organized_by.is_a? LightService::Organizer::Iterator

      context.number += 1
    end

    rolled_back do |context|
      context.number -= 1
    end
  end

  class AddsTwoWithRollbackAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      context.number += 2
    end

    rolled_back do |context|
      context.number -= 2
    end
  end

  class FailsWithRollbackWhenReachesTwelve
    extend LightService::Action
    expects :number

    executed do |context|
      context.fail_with_rollback!("10 was reached, failing with rollback") \
        if context.number >= 12
    end
  end

  class ConcatenateString
    extend LightService::Action
    expects :string,
            :word
    promises :string

    executed do |context|
      context.string.concat context.word
    end

    rolled_back do |context|
      context.string.chomp! context.word
    end
  end

  class ConcatenateStringBar
    extend LightService::Action
    expects :string
    promises :string

    executed do |context|
      context.string.concat 'bar'
    end

    rolled_back do |context|
      context.string.chomp! 'bar'
    end
  end

  class ReverseString
    extend LightService::Action
    expects :string,
            :word
    promises :string

    executed do |context|
      context.string.reverse!
    end

    rolled_back do |context|
      context.string.reverse!
    end
  end

  class CallRollback
    extend LightService::Action

    executed do |context|
      context.fail_with_rollback!('Arbitrary rollback.')
    end
  end

  class CallRollbackIfSpam
    extend LightService::Action
    expects :word

    executed do |context|
      if context.word == 'spam'
        context.fail_with_rollback!('Arbitrary rollback.')
      end
    end
  end

  class TestIterate
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .reduce([iterate(:counters,
                         [AddsOneWithRollbackAction,
                          AddsTwoWithRollbackAction,
                          FailsWithRollbackWhenReachesTwelve])])
    end

    def self.call_single(context)
      with(context)
        .reduce([iterate(:counters,
                         AddsOneWithRollbackAction)])
    end
  end

  class TestIterateIteratorSelfConscious
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .reduce([iterate(:counters,
                         [AddsOneWithRollbackAction,
                          AddsOneWithRollbackSelfConsciousAction,
                          AddsTwoWithRollbackAction,
                          FailsWithRollbackWhenReachesTwelve])])
    end

    def self.call_single(context)
      with(context)
        .reduce([iterate(:counters,
                         AddsOneWithRollbackAction)])
    end
  end

  class OrderDependentSingleIteratedAction
    extend LightService::Organizer

    def self.call(string:, words:)
      with(:string => string, :words => words).reduce(
        iterate(:words, IterateSpec::ConcatenateString),
        IterateSpec::CallRollback
      )
    end
  end

  class OrderDependentMultipleIteratedActions
    extend LightService::Organizer

    def self.call(string:, words:)
      with(:string => string, :words => words).reduce(
        IterateSpec::ConcatenateStringBar,
        iterate(
          :words,
          [IterateSpec::ConcatenateString, IterateSpec::ReverseString]
        ),
        IterateSpec::CallRollback
      )
    end
  end

  class OrderDependentRolledbackWhileIterating
    extend LightService::Organizer

    def self.call(string:, words:)
      with(:string => string, :words => words).reduce(
        iterate(
          :words,
          [
            IterateSpec::ConcatenateString,
            IterateSpec::CallRollbackIfSpam,
            IterateSpec::ReverseString
          ]
        )
      )
    end
  end
end

RSpec.describe LightService::Organizer do
  let(:empty_context) { LightService::Context.make }

  it 'reduces each item of a collection and singularizes the collection key' do
    result = IterateSpec::TestIterate.call(:number => 1,
                                           :counters => [1, 2])

    expect(result).to be_success
    expect(result.number).to eq(7)
  end

  it 'rolls back the actions when it reaches 10' do
    result = IterateSpec::TestIterate.call(:number => 1,
                                           :counters => [1, 2, 3, 4])

    expect(result).to be_failure
    expect(result.number).to eq(1)
  end

  it 'accepts a single action or organizer' do
    result = IterateSpec::TestIterate.call_single(:number => 1,
                                                  :counters => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it "knows that it's being iterated from within an organizer" do
    result = IterateSpec::TestIterateIteratorSelfConscious
             .call(:number => 1, :counters => [1, 2, 3])

    # We're raising an exception within an iterated action if `organized_by`
    # would not be asexpected.
    expect(result).to be_failure
    # Once back from the iterator, the organizer is expected to be
    # the initially called one
    expect(result.organized_by)
      .to be IterateSpec::TestIterateIteratorSelfConscious
  end

  it 'will not iterate over a failed context' do
    empty_context.fail!('Something bad happened')

    result = IterateSpec::TestIterate.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not iterate over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = IterateSpec::TestIterate.call(empty_context)
    expect(result).to be_success
  end

  context 'when the order of the iterated collection is important' do
    context 'with a single iterated action' do
      it 'will apply rollback on each action with in correct order' do
        result = IterateSpec::OrderDependentSingleIteratedAction.call(
          :string => 'sausage',
          :words => %w[bacon spam]
        )
        expect(result.fetch(:string)).to eq('sausage')
      end
    end

    context 'with multiple iterated actions' do
      it 'will apply rollback on each action in correct order' do
        result = IterateSpec::OrderDependentMultipleIteratedActions.call(
          :string => 'sausage',
          :words => %w[bacon spam]
        )
        expect(result.fetch(:string)).to eq('sausage')
      end
    end

    context 'when rolles back in the middle of the iteration' do
      it 'will apply rollback on each action in correct order' do
        result = IterateSpec::OrderDependentRolledbackWhileIterating.call(
          :string => 'sausage',
          :words => %w[bacon spam]
        )
        expect(result.fetch(:string)).to eq('sausage')
      end
    end
  end
end
