require 'spec_helper'
require 'test_doubles'

class AdditionOrganizerContextFactory
  def self.make_for(action, number)
    number += 3 # You can add more logic to prepare your context

    LightService::Testing::ContextFactory
      .make_from(TestDoubles::AdditionOrganizer)
      .for(action)
      .with(number)
  end
end

RSpec.describe TestDoubles::AddsThreeAction do
  it 'creates a context for the action with ContextFactory wrapper' do
    context =
      AdditionOrganizerContextFactory
      .make_for(TestDoubles::AddsThreeAction, 1)

    expect(context.number).to eq(7)
  end

  it 'creates a context for the action using the ContextFactory' do
    context =
      LightService::Testing::ContextFactory
      .make_from(TestDoubles::AdditionOrganizer)
      .for(TestDoubles::AddsThreeAction)
      .with(4) # Context is a "glorified" hash

    expect(context.number).to eq(7)
  end

  it "works with multiple arguments passed to Organizer's call method" do
    context = LightService::Testing::ContextFactory
              .make_from(TestDoubles::ExtraArgumentAdditionOrganizer)
              .for(described_class)
              .with(4, 2)

    expect(context.number).to eq(9)
  end
end

RSpec.describe TestDoubles::AddsTwoAction do
  it 'does not execute a callback entirely from a ContextFactory' do
    context = LightService::Testing::ContextFactory
              .make_from(TestDoubles::CallbackOrganizer)
              .for(described_class)
              .with(:number => 0)

    # add 1, add 10, then stop before executing first add 2
    expect(context.number).to eq(11)
  end
end
