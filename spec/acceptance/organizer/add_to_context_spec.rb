require 'spec_helper'

RSpec.describe LightService::Organizer do
  class TestAddToContext
    extend LightService::Organizer

    def self.call(context = LightService::Context.make)
      with(context).reduce(steps)
    end

    def self.steps
      [
        # This will add the `:number` key to the context
        # with the value of 0, so it's available for
        # AddsOneAction
        add_to_context(:number => 0),
        TestDoubles::AddsOneAction,
        add_to_context(:something => 'hello')
      ]
    end
  end

  it 'adds items to the context on the fly' do
    result = TestAddToContext.call

    expect(result).to be_success
    expect(result.number).to eq(1)
    expect(result[:something]).to eq('hello')
  end
end
