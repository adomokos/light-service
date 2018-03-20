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
        .with(:number => 1)

      expect(ctx[:number]).to eq(1)
    end
  end

  context 'when called with the second action' do
    it 'adds one to the number provided' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsTwoAction)
        .with(:number => 1)

      expect(ctx.number).to eq(2)
    end
  end

  context 'when called with third action' do
    it 'creates a context up-to the action defined' do
      ctx =
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:number => 1)

      expect(ctx.number).to eq(4)
    end
  end

  context 'when called with an invalid action' do
    let(:invalid_action) { TestDoubles::MakesLatteAction }

    it 'raises an argument error' do
      expect {
        LightService::Testing::ContextFactory
          .make_from(organizer)
          .for(invalid_action)
          .with(:number => 1)
      }.to raise_error(
        ArgumentError,
        "#{invalid_action} is not in #{organizer}"
      )
    end
  end
end

RSpec.describe LightService::Testing::ContextFactory::ActionParser do

  subject { described_class.new(action_source) }

  context 'when given sets in an organizer' do
    let(:actions) { [TestDoubles::AddsOneAction, [TestDoubles::AddsTwoAction]] }
    let(:action_source) { 'AddsOneAction, [ AddsTwoAction, AddsThreeAction ]' }
    let(:namespaces) { [TestDoubles] }

    it 'tokenizes them' do
      expect(subject.tokens.count).to eq(5)
    end

    it 'compounds them correctly' do
      rebuilt_actions = subject.rebuild_to(TestDoubles::AddsThreeAction, namespaces)

      expect(rebuilt_actions).to eq(actions)
    end

    context 'that are nested' do
      let(:actions) do
        [ TestDoubles::AddsOneAction, [
            TestDoubles::AddsTwoAction, [
              TestDoubles::AddsTwoAction, [
                TestDoubles::AddsTwoAction, [
                  TestDoubles::AddsTwoAction
          ]]]]]
      end
      let(:action_source) do
        'AddsOneAction, [ AddsTwoAction, [ AddsTwoAction, [ AddsTwoAction, [ AddsTwoAction, AddsThreeAction ] ] ] ]'
      end
      let(:namespaces) { [TestDoubles] }

      it 'compounds them correctly' do
        rebuilt_actions = subject.rebuild_to(TestDoubles::AddsThreeAction, namespaces)

        expect(rebuilt_actions).to eq(actions)
      end
    end
  end

  context 'when given an organizer method' do
    let(:action_source) { 'AddsOneAction, with_callback(AddsTwoAction, [ AddsThreeAction ])' }

    it 'tokenizes them' do
      expect(subject.tokens.count).to eq(6)
    end
  end
end

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

RSpec.describe 'ContextFactory - used with IterateOrganizer' do
  let(:organizer) { TestDoubles::IterateOrganizer }

  context 'when called with the callback action' do
    it 'creates a context up-to the action defined if that is a method argument' do
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
      expect {
        LightService::Testing::ContextFactory
        .make_from(organizer)
        .for(TestDoubles::AddsThreeAction)
        .with(:numbers => [1, 2])
      }.to raise_error(
        RuntimeError, "Cannot partially iterate an Organizer with a ContextFactory"
      )
    end
  end
end
