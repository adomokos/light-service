require 'spec_helper'
require 'test_doubles'

describe 'ContextFactory - used with AdditionOrganizer' do
  let(:organizer) { TestDoubles::AdditionOrganizer }

  context 'when called with the first action' do
    it 'does not alter the context' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsOneAction)
        .with(1)

      expect(ctx[:number]).to eq(1)
    end
  end

  context 'when called with the second action' do
    it 'adds one to the number provided' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(1)

      expect(ctx.number).to eq(2)
    end
  end

  context 'when called with third action' do
    it 'creates a context up-to the action defined' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(1)

      expect(ctx.number).to eq(4)
    end
  end
end
