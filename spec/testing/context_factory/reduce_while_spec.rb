require 'spec_helper'
require 'test_doubles'

RSpec.describe 'ContextFactory - used with ReduceWhileOrganizer' do
  let(:organizer) { TestDoubles::ReduceWhileOrganizer }

  context 'when called with truthy block' do
    it 'creates a context up-to the action defined before the reduce_while' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx[:number]).to eq(2)
    end

    it 'creates a context up-to the second step of the reduce_while' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(4)
    end
  end

  context 'when called with falsey block' do
    it 'creates a context without executing the steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 7)

      expect(ctx[:number]).to eq(8)
    end
  end
end
