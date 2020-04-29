require 'spec_helper'

RSpec.describe LightService::Organizer do
  class TestAddAliases
    extend LightService::Organizer

    def self.call(context = LightService::Context.make)
      with(context).reduce(steps)
    end

    def self.steps
      [
        add_to_context(:my_message => 'Hello There'),
        # This will add the alias `:a_message` which points
        # to the :my_message key's value
        add_aliases(:my_message => :a_message),
        TestDoubles::CapitalizeMessage
      ]
    end
  end

  it 'adds aliases to the context embedded in the series of actions' do
    result = TestAddAliases.call

    expect(result).to be_success
    expect(result.final_message).to eq('HELLO THERE')
  end
end
