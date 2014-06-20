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

    class PromisingAction
      include LightService::Action
      promises :milk_tea
    end

    let(:context) { ::LightService::Context.make }

    context "when the action context has failure" do
      it "returns immediately" do
        context.fail!("an error")

        DummyAction.execute(context)

        expect(context.to_hash.keys).to be_empty
      end
    end

    context "when the action context does not have failure" do
      it "executes the block" do
        DummyAction.execute(context)

        expect(context.to_hash.keys).to eq [:test_key]
      end
    end

    context "when the action context skips all" do
      it "returns immediately" do
        context.skip_all!

        DummyAction.execute(context)

        expect(context.to_hash.keys).to be_empty
      end

      it "does not execute skipped actions" do
        DummyAction.execute(context)

        context.skip_all!

        SkippedAction.execute(context)

        expect(context.to_hash).to eq ({test_key: "test_value"})
      end
    end

    it "returns the context" do
      result = DummyAction.execute(context)

      expect(result.to_hash).to eq ({test_key: "test_value"})
    end

    context "when invoked with hash" do
      it "creates LightService::Context implicitly" do
        result = DummyAction.execute(some_key: "some value")

        expect(result).to be_success
        expect(result.keys).to eq([:some_key, :test_key])
      end
    end
    context "when invoked without arguments" do
      it "creates LightService::Context implicitly" do
        result = DummyAction.execute

        expect(result).to be_success
        expect(result.keys).to eq([:test_key])
      end
    end
  end
end
