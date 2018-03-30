require 'spec_helper'
require 'test_doubles'

RSpec.describe 'Action after_actions' do
  describe 'works with simple organizers - from outside' do
    it 'can be used to inject code block before each action' do
      TestDoubles::AdditionOrganizer.after_actions =
        lambda do |ctx|
          ctx.number -= 2 if ctx.current_action == TestDoubles::AddsThreeAction
        end

      result = TestDoubles::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(4)
    end

    it 'works with iterator' do
      TestDoubles::TestIterate.after_actions = [
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
    module AfterActions
      class AdditionOrganizer
        extend LightService::Organizer
        after_actions (lambda do |ctx|
                         if ctx.current_action == TestDoubles::AddsOneAction
                           ctx.number -= 2
                         end
                       end),
                      (lambda do |ctx|
                         if ctx.current_action == TestDoubles::AddsThreeAction
                           ctx.number -= 3
                         end
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

    it 'accepts after_actions hook lambdas from organizer' do
      result = AfterActions::AdditionOrganizer.call(0)

      expect(result.fetch(:number)).to eq(1)
    end
  end
end
