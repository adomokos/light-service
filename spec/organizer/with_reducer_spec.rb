require 'spec_helper'
require 'test_doubles'

describe LightService::Organizer::WithReducer do
  let(:context) { LightService::Context.make }
  let(:action1) { double }
  let(:action2) { double }
  let(:actions) { [action1, action2] }

  it "reduces the provided actions" do
    expect(action1).to receive(:execute).with(context).and_return(context)
    expect(action2).to receive(:execute).with(context).and_return(context)

    result = described_class.new.with(context).reduce(actions)

    expect(result).to eq(context)
    expect(result).to be_success
  end
end
