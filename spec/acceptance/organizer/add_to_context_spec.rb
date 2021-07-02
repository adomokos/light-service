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
        add_to_context(:message => "Just a message"),
        add_to_context(:error_code => "D0H"),
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

  it 'adds items to the context as accessors' do
    result = TestAddToContext.call

    expect(result).to be_success
    expect(result.something).to eq('hello')
  end

  it "will not add items as accessors when they are reserved" do
    result = TestAddToContext.call

    expect(result).to be_success

    expect(result.message).to be_blank
    expect(result[:message]).to eq "Just a message"

    expect(result.error_code).to be_blank
    expect(result[:error_code]).to eq "D0H"
  end
end
