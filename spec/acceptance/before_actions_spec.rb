require 'spec_helper'
require 'test_doubles'

RSpec.describe 'Action before_actions' do
  describe 'works with simple organizers - from outside' do
    it 'can be used to inject code block before each action' do
      TestDoubles::AdditionOrganizer.before_actions =
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsThreeAction
        end

      result = TestDoubles::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(4)
    end

    it 'works with iterator' do
      TestDoubles::TestIterate.before_actions = [
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsOneAction
        end
      ]

      result = TestDoubles::TestIterate.call(:number => 0,
                                             :counters => [1, 2, 3, 4])

      expect(result).to be_success
      expect(result.number).to eq(-4)
    end
  end

  describe 'can be added to organizers declaratively' do
    module BeforeActions
      class AdditionOrganizer
        extend LightService::Organizer
        before_actions (lambda do |ctx|
                          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsOneAction
                        end),
                       (lambda do |ctx|
                          ctx.number -= 3 if ctx.current_action == TestDoubles::AddsThreeAction
                        end)

        def self.call(number)
          with(:number => number).reduce(actions)
        end

        def self.actions
          [
            TestDoubles::AddsOneAction,
            TestDoubles::AddsTwoAction,
            TestDoubles::AddsThreeAction
          ]
        end
      end
    end

    it 'accepts before_actions hook lambdas from organizer' do
      result = BeforeActions::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(1)
    end
  end

  describe 'works with callbacks' do
    it 'can interact with actions from the outside' do
      TestDoubles::TestWithCallback.before_actions = [
        lambda do |ctx|
          ctx.total -= 1000 if ctx.current_action == TestDoubles::AddToTotalAction
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
      TestDoubles::TestWithCallback.before_actions = [
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
