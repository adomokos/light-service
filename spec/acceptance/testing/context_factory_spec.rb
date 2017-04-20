require 'spec_helper'
require 'test_doubles'
require 'light-service/testing'

class AdditionOrganizerContextFactory
  def self.make_for(action, number)
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
      .make_for(TestDoubles::AddsThreeAction, 4)

    expect(context.number).to eq(7)
  end

  it "creates a context for the action using the ContextFactory" do
    context =
      LightService::Testing::ContextFactory
      .make_from(TestDoubles::AdditionOrganizer)
      .for(TestDoubles::AddsThreeAction)
      .with(:number => 4)

    expect(context.number).to eq(7)
  end
end
