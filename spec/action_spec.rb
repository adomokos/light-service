require 'spec_helper'

module LightService
  describe Action do
    class DummyAction
      include LightService::Action

      executed do |context|
        context[:test_key] = "test_value"
      end
    end

    class SkippedAction
      include LightService::Action

      executed do |context|
        context[:test_key] = "set_by_skipped_action"
      end
    end

    let(:context) { ::LightService::Context.make }

    context "when the action context has failure" do
      it "returns immediately" do
        context.set_failure!("an error")

        DummyAction.execute(context)

        context.to_hash.keys.should be_empty
      end
    end

    context "when the action context does not have failure" do
      it "executes the block" do
        DummyAction.execute(context)

        context.to_hash.keys.should eq [:test_key]
      end
    end

    context "when the action context skips all" do
      it "returns immediately" do
        context.skip_all!

        DummyAction.execute(context)

        context.to_hash.keys.should be_empty
      end

      it "does not execute skipped actions" do
        DummyAction.execute(context)

        context.skip_all!

        SkippedAction.execute(context)

        context.to_hash.should eq ({:test_key => "test_value"})
      end
    end

    it "returns the context" do
      result = DummyAction.execute(context)

      result.to_hash.should eq ({:test_key => "test_value"})
    end

    context "can take hash as an argument" do
      it "creates LightService::Context implicitly" do
        result = DummyAction.execute(some_key: "some value")

        expect(result).to be_success
        expect(result.keys).to eq([:some_key, :test_key])
      end
    end
  end
end
