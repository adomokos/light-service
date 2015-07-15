require 'spec_helper'
require 'test_doubles'

describe LightService::Organizer do

  let(:context) { LightService::Context.make(:user => user) }
  let(:user) { double(:user) }

  context "when #with is called with hash" do
    before do
      expect(TestDoubles::AnAction).to receive(:execute) \
              .with(context) \
              .and_return context
      expect(TestDoubles::AnotherAction).to receive(:execute) \
              .with(context) \
              .and_return context
    end

    it "implicitly creates a Context" do
      result = TestDoubles::AnOrganizer.do_something(:user => user)
      expect(result).to eq(context)
    end
  end

  context "when #with is called with Context" do
    before do
      expect(TestDoubles::AnAction).to receive(:execute) \
              .with(context) \
              .and_return context
      expect(TestDoubles::AnotherAction).to receive(:execute) \
              .with(context) \
              .and_return context
    end

    it "uses that Context without recreating it" do
      result = TestDoubles::AnOrganizer.do_something(context)
      expect(result).to eq(context)
    end
  end

  context "when no Actions are specified" do
    it "throws a Runtime error" do
      expect { TestDoubles::AnOrganizer.do_something_with_no_actions(context) }.to \
        raise_error RuntimeError, "No action(s) were provided"
    end
  end

  context "when no starting context is specified" do
    it "creates one implicitly" do
      expect(TestDoubles::AnAction).to receive(:execute) \
        .with({}) \
        .and_return(context)
      expect(TestDoubles::AnotherAction).to receive(:execute) \
        .with(context) \
        .and_return(context)

      expect { TestDoubles::AnOrganizer.do_something_with_no_starting_context } \
        .not_to raise_error
    end
  end

  context "when the organizer is also an action", "and the organizer rescues exceptions of its sub-actions" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer
        extend LightService::Action

        executed do |ctx|
          begin
            with(ctx).
              reduce(TestDoubles::MakesTeaPromisingKeyButRaisesException)
          rescue
          end
        end
      end
    end

    it "does not raise an error concerning a sub-action's missing keys" do
      expect { organizer.execute }.not_to raise_error
    end
  end

  context "when aliases are declared" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer
        aliases :foo => :bar

        def self.do_stuff
          with.reduce(TestDoubles::AnAction)
        end
      end
    end

    it "merges the aliases into the data" do
      with_reducer = double(reduce: true)

      allow(described_class::WithReducerFactory).to receive(:make).
        and_return(with_reducer)

      expect(with_reducer).to \
        receive(:with).
        with(hash_including(:_aliases => { :foo => :bar })).
        and_return(with_reducer)

      organizer.do_stuff
    end
  end

end
