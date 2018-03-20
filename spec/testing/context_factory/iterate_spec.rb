require 'spec_helper'
require 'test_doubles'

RSpec.describe 'ContextFactory - used with IterateOrganizer' do
  let(:organizer) { TestDoubles::IterateOrganizer }

  context 'when called with the callback action' do
    it 'creates a context up-to the action defined before the iteration' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsOneIteratesAction)
        .with(:numbers => [1, 2])

      expect(ctx[:numbers]).to eq([1, 2])
    end

    it 'creates a context up-to iteration with empty context steps' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:numbers => [1, 2])

      expect(ctx.numbers).to eq([2, 3])
    end

    it 'errors on an iteration looking for action defined in context steps' do
      expect do
        LightService::Testing::ContextFactory
          .make_from(organizer)
          .for(TestDoubles::AddsThreeAction)
          .with(:numbers => [1, 2])
      end.to raise_error(
        RuntimeError,
        "Cannot partially iterate in an Organizer with a ContextFactory"
      )
    end
  end
end
