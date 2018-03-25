require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  describe 'a simple case with a single callback' do
    it 'calls the actions defined with callback' do
      result = TestDoubles::TestWithCallback.call

      expect(result.counter).to eq(3)
      expect(result.total).to eq(6)
    end
  end

  describe 'a more complex example with nested callbacks' do
    class TestWithNestedCallback
      extend LightService::Organizer

      def self.call(context = {})
        with(context).reduce(actions)
      end

      def self.actions
        [
          SetUpNestedContextAction,
          with_callback(IterateOuterCollectionAction,
                        [IncrementOuterCountAction,
                         with_callback(TestDoubles::IterateCollectionAction,
                                       [TestDoubles::IncrementCountAction,
                                        TestDoubles::AddToTotalAction])])
        ]
      end
    end

    class SetUpNestedContextAction
      extend LightService::Action
      promises :outer_numbers, :outer_counter,
               :numbers, :counter, :total

      executed do |ctx|
        ctx.outer_numbers = [12, 17]
        ctx.outer_counter = 0
        ctx.numbers = [1, 2, 3]
        ctx.counter = 0
        ctx.total = 0
      end
    end

    class IterateOuterCollectionAction
      extend LightService::Action
      expects :outer_numbers, :callback
      promises :outer_number

      executed do |ctx|
        ctx.outer_numbers.each do |outer_number|
          ctx.outer_number = outer_number
          ctx.callback.call(ctx)
        end
      end
    end

    class IncrementOuterCountAction
      extend LightService::Action
      expects :outer_counter

      executed do |ctx|
        ctx.outer_counter = ctx.outer_counter + 1
      end
    end

    it 'calls both the action and the nested callbacks' do
      result = TestWithNestedCallback.call

      expect(result.outer_counter).to eq(2)
      # Counts and total are the duplicates of
      # what you'll see in the simple spec,
      # as the internal callback logic is called
      # twice due to 2 items in the outer_numbers
      # collection.
      expect(result.counter).to eq(6)
      expect(result.total).to eq(12)
    end
  end

  describe 'with failed or skipped context' do
    class TestWithFailureCallback
      extend LightService::Organizer

      def self.call(context = {})
        with(context).reduce(actions)
      end

      def self.actions
        [
          TestDoubles::SetUpContextAction,
          with_callback(TestDoubles::IterateCollectionAction,
                        [TestDoubles::IncrementCountAction,
                         TestDoubles::FailureAction])
        ]
      end
    end

    it 'will not process the routine' do
      result = TestWithFailureCallback.call

      expect(result).to be_failure
      expect(result.counter).to eq(1)
      expect(result.total).to eq(0)
    end
  end
end
