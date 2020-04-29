require 'spec_helper'
require 'test_doubles'

describe LightService::Organizer do
  let(:ctx) { LightService::Context.make(:user => user) }
  let(:user) { double(:user) }

  context "when #with is called with hash" do
    before do
      expect(TestDoubles::AnAction).to receive(:execute)
        .with(ctx)
        .and_return(ctx)
      expect(TestDoubles::AnotherAction).to receive(:execute)
        .with(ctx)
        .and_return(ctx)
    end

    it "implicitly creates a Context" do
      result = TestDoubles::AnOrganizer.call(:user => user)
      expect(result).to eq(ctx)
    end
  end

  context "when #with is called with Context" do
    before do
      expect(TestDoubles::AnAction).to receive(:execute)
        .with(ctx)
        .and_return(ctx)
      expect(TestDoubles::AnotherAction).to receive(:execute)
        .with(ctx)
        .and_return(ctx)
    end

    it "uses that Context without recreating it" do
      result = TestDoubles::AnOrganizer.call(ctx)
      expect(result).to eq(ctx)
    end
  end

  context "when no Actions are specified" do
    it "throws a Runtime error" do
      expect { TestDoubles::AnOrganizer.do_something_with_no_actions(ctx) }.to \
        raise_error(RuntimeError, "No action(s) were provided")
    end
  end

  context "when aliases are declared" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer
        aliases :foo => :bar

        def self.call
          with.reduce(TestDoubles::AnAction)
        end
      end
    end

    it "merges the aliases into the data" do
      with_reducer = double(:reduce => true)

      allow(described_class::WithReducerFactory).to receive(:make)
        .and_return(with_reducer)

      expect(with_reducer).to receive(:with)
        .with(hash_including(:_aliases => { :foo => :bar }))
        .and_return(with_reducer)

      organizer.call
    end
  end

  context "when an organizer is nested and reduced within another" do
    let(:reduced) { TestDoubles::NestingOrganizer.call(ctx) }
    let(:organizer_result) do
      TestDoubles::NotExplicitlyReturningContextOrganizer.call(ctx)
    end

    it "reduces an organizer which returns something" do
      expect(organizer_result).to eq([1, 2, 3])
    end

    it "adds :foo and :bar to the context" do
      reduced
      expect(ctx[:foo]).to eq([1, 2, 3])
      expect(ctx[:bar]).to eq(ctx[:foo])
    end

    it "returns the context" do
      expect(reduced).to eq(ctx)
    end
  end

  context 'can add items to the context' do
    specify 'with #add_to_context' do
      result = TestDoubles::AnOrganizerThatAddsToContext.call
      expect(result[:strongest_avenger]).to eq 'The Thor'
      expect(result[:last_jedi]).to eq 'Rey'
    end
  end

  context 'can assign key aliaeses' do
    it 'with #add_aliases' do
      result = TestDoubles::AnOrganizerThatAddsAliases.call
      expect(result[:foo]).to eq :bar
      expect(result[:baz]).to eq :bar
    end
  end
end
