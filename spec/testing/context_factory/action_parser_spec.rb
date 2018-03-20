require 'spec_helper'
require 'test_doubles'

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
