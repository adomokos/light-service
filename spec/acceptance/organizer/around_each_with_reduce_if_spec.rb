require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceIfWithAroundEach
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .around_each(TestDoubles::AroundEachLoggerHandler)
        .reduce(actions)
    end

    def self.actions
      [
        TestDoubles::AddsOneAction,
        reduce_if(->(ctx) { ctx.number == 1 },
                  TestDoubles::AddsOneAction)
      ]
    end
  end

  it 'can be used to log data' do
    result =
      TestReduceIfWithAroundEach
      .call(:number => 0,
            :logger => TestDoubles::TestLogger.new)

    expect(result.fetch(:number)).to eq(2)
    expect(result[:logger].logs).to eq(
      [{
        :action => TestDoubles::AddsOneAction,
        :before => 0,
        :after => 1
      }, {
        :action => TestDoubles::AddsOneAction,
        :before => 1,
        :after => 2
      }]
    )
  end
end
