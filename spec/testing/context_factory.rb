require 'spec_helper'
require 'test_doubles'
require 'light-service/testing'

describe 'ContextFactory - used with AdditionOrganizer' do
  context 'when called with the first action' do
    it 'does not alter the context' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(TestDoubles::AdditionOrganizer)
        .for(TestDoubles::AddsOneAction)
        .with(:number => 1)

      expect(ctx[:number]).to eq(1)
    end
  end

  context 'when called with the second action' do
    it 'adds one to the number provided' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(TestDoubles::AdditionOrganizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx.number).to eq(2)
    end
  end

  context 'when called with third action' do
    it 'creates a context up-to the action defined' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(TestDoubles::AdditionOrganizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(4)
    end
  end
end
