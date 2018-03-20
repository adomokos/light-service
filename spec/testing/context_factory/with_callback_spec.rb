require 'spec_helper'
require 'test_doubles'

RSpec.describe 'ContextFactory - used with CallbackOrganizer' do
  let(:organizer) { TestDoubles::CallbackOrganizer }

  context 'when called with the callback action' do
    it 'creates a context up-to the action defined if that is a method argument' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddTenCallbackAction)
        .with(:number => 1)

      expect(ctx.number).to eq(2)
    end

    it 'creates a context up-to callback action with empty context steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx.number).to eq(12)
    end

    it 'creates a context up-to the action defined in context steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(14)
    end
  end
end
