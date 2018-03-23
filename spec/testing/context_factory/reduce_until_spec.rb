require 'spec_helper'
require 'test_doubles'

RSpec.describe 'ContextFactory - used with ReduceUntilOrganizer' do
  let(:organizer) { TestDoubles::ReduceUntilOrganizer }

  context 'when called with truthy block' do
    it 'creates a context up-to the action defined before the iteration' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx[:number]).to eq(2)
    end

    it 'creates a context only to the first step of the loop' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(4)
    end
  end

  context 'when called with falsey block' do
    it 'creates a context up-to the first step' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 7)

      expect(ctx[:number]).to eq(10)
    end
  end
end
