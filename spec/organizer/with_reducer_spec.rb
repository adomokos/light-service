require 'spec_helper'
require 'test_doubles'

describe LightService::Organizer::WithReducer do
  let(:context) { LightService::Context.make }
  let(:action1) { TestDoubles::NullAction }
  let(:action2) { TestDoubles::NullAction.clone }
  let(:actions) { [action1, action2] }

  before { context.current_action = action2 }

  it "reduces the provided actions" do
    result = described_class.new.with(context).reduce(actions)

    expect(result).to eq(context)
    expect(result).to be_success
  end

  it "executes a handler around each action and continues reducing" do
    expect(action1).to receive(:execute).with(context).and_return(context)

    result = described_class.new.with(context)
                            .around_each(TestDoubles::AroundEachNullHandler)
                            .reduce([action1])

    expect(result).to eq(context)
    expect(result).to be_success
  end

  context "when FailWithRollbackError is caught" do
    it "reduces the rollback" do
      expect(action1).to receive(:execute).with(context).and_return(context)
      expect(action2).to receive(:execute).with(context) do
        raise LightService::FailWithRollbackError
      end
      expect(action1).to receive(:rollback).with(context).and_return(context)
      expect(action2).to receive(:rollback).with(context).and_return(context)

      result = described_class.new.with(context).reduce(actions)

      expect(result).to eq(context)
    end

    it "reduces the rollback with an action without `rollback`" do
      expect(action1).to receive(:execute).with(context).and_return(context)
      expect(action2).to receive(:execute).with(context) do
        raise LightService::FailWithRollbackError
      end
      expect(action2).to receive(:rollback).with(context).and_return(context)

      result = described_class.new.with(context).reduce(actions)

      expect(result).to eq(context)
    end
  end
end
