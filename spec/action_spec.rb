require 'spec_helper'
require 'test_doubles'

describe LightService::Action do
  let(:context) { LightService::Context.make }

  context "when the action context has failure" do
    it "returns immediately" do
      context.fail!("an error")

      TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(context.to_hash.keys).to be_empty
    end

    it "returns the failure message in the context" do
      context.fail!("an error")

      returned_context = TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(returned_context.message).to eq("an error")
    end
  end

  context "when the action has an explicit success message" do
    it "returns the success message in the context" do
      context.succeed!("successful")

      returned_context = TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(returned_context.message).to eq("successful")
    end
  end

  context "when the action context does not have failure" do
    it "executes the block" do
      TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(context.to_hash.keys).to eq [:number]
      expect(context.fetch(:number)).to eq(2)
    end
  end

  context "when the action context skips all" do
    it "returns immediately" do
      context.skip_remaining!

      TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(context.to_hash.keys).to be_empty
    end

    it "does not execute skipped actions" do
      TestDoubles::AddsTwoActionWithFetch.execute(context)
      expect(context.to_hash).to eq(:number => 2)

      context.skip_remaining!

      TestDoubles::AddsTwoActionWithFetch.execute(context)
      # Since the action was skipped, the number remains 2
      expect(context.to_hash).to eq(:number => 2)
    end
  end

  it "returns the context" do
    result = TestDoubles::AddsTwoActionWithFetch.execute(context)

    expect(result.to_hash).to eq(:number => 2)
  end

  context "when called directly" do
    it "is expected to not be organized" do
      result = TestDoubles::AddsTwoActionWithFetch.execute(context)

      expect(result.organized_by).to be_nil
    end
  end

  context "when invoked with hash" do
    it "creates LightService::Context implicitly" do
      ctx = { :some_key => "some value" }
      result = TestDoubles::AddsTwoActionWithFetch.execute(ctx)

      expect(result).to be_success
      expect(result.keys).to eq(%i[some_key number])
    end
  end

  context "when invoked without arguments" do
    it "creates LightService::Context implicitly" do
      result = TestDoubles::AddsTwoActionWithFetch.execute

      expect(result).to be_success
      expect(result.keys).to eq([:number])
    end
  end
end
