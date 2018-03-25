require 'spec_helper'
require 'test_doubles'

RSpec.describe 'Action before hooks' do
  describe 'works with simple organizers' do
    it 'can be used to inject code block before each action' do
      TestDoubles::AdditionOrganizer.before_action = [
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsThreeAction
        end
      ]

      result = TestDoubles::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(4)
    end

    it 'Adds 1, 2 and 3 to the initial value of 1' do
      TestDoubles::TestIterate.before_action = [
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsOneAction
        end
      ]

      result = TestDoubles::TestIterate.call(:numbers => [1, 2, 3, 4])

      expect(result).to be_success
      expect(result.number).to eq(3)
    end
  end

  describe 'works with callbacks' do
    it 'can interact with actions from the outside' do
      TestDoubles::TestWithCallback.before_action = [
        lambda do |ctx|
          if ctx.current_action == TestDoubles::AddToTotalAction
            ctx.total -= 1000
          end
        end
      ]
      result = TestDoubles::TestWithCallback.call

      expect(result.counter).to eq(3)
      expect(result.total).to eq(-2994)
    end
  end

  describe 'can halt all execution with a raised error' do
    it 'does not call the rest of the callback steps' do
      class SkipContextError < StandardError
        attr_reader :ctx

        def initialize(msg, ctx)
          @ctx = ctx
          super(msg)
        end
      end
      TestDoubles::TestWithCallback.before_action = [
        lambda do |ctx|
          if ctx.current_action == TestDoubles::IncrementCountAction
            ctx.total -= 1000
            raise SkipContextError.new("stop context now", ctx)
          end
        end
      ]
      begin
        TestDoubles::TestWithCallback.call
      rescue SkipContextError => e
        expect(e.ctx).not_to be_empty
      end
    end
  end
end
