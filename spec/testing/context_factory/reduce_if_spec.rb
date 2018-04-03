require 'spec_helper'
require 'test_doubles'

RSpec.describe 'ContextFactory - used with ReduceIfOrganizer' do
  let(:organizer) { TestDoubles::ReduceIfOrganizer }

  context 'when called with a truthy argument action' do
    it 'executes a context up-to the callback action' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(4)
    end

    it 'creates a context up-to action with empty context steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx.number).to eq(2)
    end
  end

  context 'when called with a false argument action' do
    it 'does not execute the steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 0)

      expect(ctx.number).to eq(1)
    end
  end
end
