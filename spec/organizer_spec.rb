require 'spec_helper'

describe LightService::Organizer do
  class AnAction; end
  class AnotherAction; end

  class AnOrganizer
    include LightService::Organizer

    def self.some_method(user)
      with(user: user).reduce([AnAction, AnotherAction])
    end

    def self.some_method_with(user)
      context = LightService::Context.make(user: user)
      with(context).reduce(AnAction, AnotherAction)
    end

    def self.some_method_with_no_actions(user)
      context = LightService::Context.make(user: user)
      with(context).reduce
    end
  end

  let(:context) { ::LightService::Context.make(user: user) }
  let(:user) { double(:user) }

  context "when #with is called with hash" do
    before do
      AnAction.should_receive(:execute) \
              .with(context) \
              .and_return context
      AnotherAction.should_receive(:execute) \
              .with(context) \
              .and_return context
    end

    it "creates a Context" do
      result = AnOrganizer.some_method(user)
      expect(result).to eq(context)
    end
  end

  context "when #with is called with Context" do
    before do
      AnAction.should_receive(:execute) \
              .with(context) \
              .and_return context
      AnotherAction.should_receive(:execute) \
              .with(context) \
              .and_return context
    end

    it "creates a Context" do
      result = AnOrganizer.some_method_with(user)
      expect(result).to eq(context)
    end
  end

  context "when no Actions are specified" do
    it "throws a Runtime error" do
      expect { AnOrganizer.some_method_with_no_actions(user) }.to \
              raise_error RuntimeError, "No action(s) were provided"
    end
  end
end
