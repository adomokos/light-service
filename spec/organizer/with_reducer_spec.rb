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
end
