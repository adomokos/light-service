require 'spec_helper'
require 'test_doubles'

class AdditionOrganizerContextFactory
  def self.make_for(action, number)
    number += 3 # You can add more logic to prepare your context

    LightService::Testing::ContextFactory
      .make_from(TestDoubles::AdditionOrganizer)
      .for(action)
      .with(:number => number)
  end
end

RSpec.describe TestDoubles::AddsThreeAction do
  it "creates a context for the action with ContextFactory wrapper" do
    context =
      AdditionOrganizerContextFactory
      .make_for(TestDoubles::AddsThreeAction, 1)

    expect(context.number).to eq(7)
  end

  it "creates a context for the action using the ContextFactory" do
    context =
      LightService::Testing::ContextFactory
      .make_from(TestDoubles::AdditionOrganizer)
      .for(TestDoubles::AddsThreeAction)
      .with(:number => 4) # Context is a "glorified" hash

    expect(context.number).to eq(7)
  end
end
