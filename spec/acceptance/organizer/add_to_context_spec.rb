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

  class TestAddToContextReservedWords
    extend LightService::Organizer

    def self.call(context = LightService::Context.make)
      with(context).reduce(steps)
    end

    def self.steps
      [
        add_to_context(:message => "yo", "error_code" => "00P5")
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
    expect { TestAddToContextReservedWords.call }.to \
      raise_error(LightService::ReservedKeysInContextError)
      .with_message(/:message, :error_code/)
  end
end
