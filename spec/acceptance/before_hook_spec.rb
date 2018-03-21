require 'spec_helper'
require 'test_doubles'

RSpec.describe 'Action before hooks' do
  module BeforeHooks
    class TestIterate
      extend LightService::Organizer

      def self.call(context)
        with(context)
          .reduce([iterate(:numbers,
                           [TestDoubles::AddsOneAction])])
      end
    end
  end

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
    BeforeHooks::TestIterate.before_action = [
      lambda do |ctx|
        ctx.number -= 2 if ctx.current_action == TestDoubles::AddsOneAction
      end
    ]

    result = BeforeHooks::TestIterate.call(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(3)
  end
end
