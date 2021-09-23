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

  context 'when there are already before_actions' do
    it 'only appends before_actions' do
      TestDoubles::AdditionOrganizer.before_actions = [
        lambda do |ctx|
          ctx[:number] += 1 \
            if ctx.current_action == TestDoubles::AddsTwoAction
        end
      ]

      context =
        LightService::Testing::ContextFactory
        .make_from(TestDoubles::AdditionOrganizer)
        .for(TestDoubles::AddsThreeAction)
        .with(4) # Context is a "glorified" hash

      expect(context.number).to eq(8)
      expect(context[:_before_actions].length).to eq(1)
    end
  end
end

describe 'ContextFactory - used with NamedArgumentOrganiser' do
  let(:organizer) { TestDoubles::NamedArgumentOrganiser }

  # it's relevant to test this as handling of named arguments changed between ruby 2.7 and 3.0
  it 'pass named arguments to the organiser' do
    ctx =
      LightService::Testing::ContextFactory
      .make_from(organizer)
      .for(TestDoubles::AddsTwoAction)
      .with(number: 2) # rubocop:disable Style/HashSyntax

    expect(ctx[:number]).to eq(2)
  end
end
