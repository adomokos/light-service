require 'spec_helper'

module LightService
  describe ActionBase do
    class DummyAction < ::LightService::ActionBase
      action_execute do |context|
        context[:test_key] = "test_value"
      end
    end

    let(:context) { ::LightService::Context.new }

    context "when the action context has failure" do
      it "returns immediately" do
        context.set_failure!("an error")

        DummyAction.execute(context)

        context.context_hash.keys.should be_empty
      end
    end

    context "when the action context does not have failure" do
      it "executes the block" do
        DummyAction.execute(context)

        context.context_hash.keys.should eq [:test_key]
      end
    end

    it "returns the context" do
      result = DummyAction.execute(context)

      result.context_hash.should eq ({:test_key => "test_value"})
    end
  end
end
