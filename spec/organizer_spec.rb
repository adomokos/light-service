require 'spec_helper'

describe LightService::Organizer do
  class AnAction; end
  class AnotherAction; end

  class AnOrganizer
    include LightService::Organizer

    def self.do_something(action_arguments)
      with(action_arguments).reduce([AnAction, AnotherAction])
    end

    def self.do_something_with_no_actions(action_arguments)
      with(action_arguments).reduce
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

    it "implicitly creates a Context" do
      result = AnOrganizer.do_something(:user => user)
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

    it "uses that Context without recreating it" do
      result = AnOrganizer.do_something(context)
      expect(result).to eq(context)
    end
  end

  context "when no Actions are specified" do
    it "throws a Runtime error" do
      expect { AnOrganizer.do_something_with_no_actions(context) }.to \
              raise_error RuntimeError, "No action(s) were provided"
    end
  end
end
