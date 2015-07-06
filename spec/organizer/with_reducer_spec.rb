require 'spec_helper'
require 'test_doubles'

describe LightService::Organizer::WithReducer do
  let(:context) { LightService::Context.make }
  let(:action1) { double(:action1) }
  let(:action2) { double(:action2) }
  let(:actions) { [action1, action2] }

  before { context.current_action = action2 }

  it "reduces the provided actions" do
    expect(action1).to receive(:execute).with(context).and_return(context)
    expect(action2).to receive(:execute).with(context).and_return(context)

    result = described_class.new.with(context).reduce(actions)

    expect(result).to eq(context)
    expect(result).to be_success
  end

  context "when FailWithRollbackError is caught" do
    it "reduces the rollback" do
      expect(action1).to receive(:execute).with(context).and_return(context)
      expect(action2).to receive(:execute).with(context) { raise LightService::FailWithRollbackError }
      expect(action1).to receive(:rollback).with(context).and_return(context)
      expect(action2).to receive(:rollback).with(context).and_return(context)

      result = described_class.new.with(context).reduce(actions)

      expect(result).to eq(context)
    end

    it "reduces the rollback with an action without `rollback`" do
      expect(action1).to receive(:execute).with(context).and_return(context)
      expect(action2).to receive(:execute).with(context) { raise LightService::FailWithRollbackError }
      expect(action2).to receive(:rollback).with(context).and_return(context)

      result = described_class.new.with(context).reduce(actions)

      expect(result).to eq(context)
    end
  end

  context "when aliases are given" do
    it "puts the aliased value in the context with the aliasing key" do
      data = LightService::Context.make({ foo: "foo" })
      aliases = {
        foo: :alias_of_foo
      }
      aliased_pair = {
        alias_of_foo: "foo"
      }

      expect(action1).to receive(:execute) \
        .with(hash_including(aliased_pair)) \
        .and_return(data)

      expect(action2).to receive(:execute) \
        .with(hash_including(aliased_pair)) \
        .and_return(data)

      described_class.new.with(data, aliases).reduce(actions)
    end
  end
end
