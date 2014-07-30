require 'spec_helper'
require 'test_doubles'

module LightService
  describe Action do

    let(:context) { ::LightService::Context.make }

    context "when the action context has failure" do
      it "returns immediately" do
        context.fail!("an error")

        TestDoubles::AddsTwoAction.execute(context)

        expect(context.to_hash.keys).to be_empty
      end
    end

    context "when the action context does not have failure" do
      it "executes the block" do
        TestDoubles::AddsTwoAction.execute(context)

        expect(context.to_hash.keys).to eq [:number]
        expect(context.fetch(:number)).to eq(2)
      end
    end

    context "when the action context skips all" do
      it "returns immediately" do
        context.skip_all!

        TestDoubles::AddsTwoAction.execute(context)

        expect(context.to_hash.keys).to be_empty
      end

      it "does not execute skipped actions" do
        TestDoubles::AddsTwoAction.execute(context)
        expect(context.to_hash).to eq ({:number => 2})

        context.skip_all!

        TestDoubles::AddsTwoAction.execute(context)
        # Since the action was skipped, the number remains 2
        expect(context.to_hash).to eq ({:number => 2})
      end
    end

    it "returns the context" do
      result = TestDoubles::AddsTwoAction.execute(context)

      expect(result.to_hash).to eq ({:number => 2})
    end

    context "when invoked with hash" do
      it "creates LightService::Context implicitly" do
        result = TestDoubles::AddsTwoAction.execute(:some_key => "some value")

        expect(result).to be_success
        expect(result.keys).to eq([:some_key, :number])
      end
    end

    context "when invoked without arguments" do
      it "creates LightService::Context implicitly" do
        result = TestDoubles::AddsTwoAction.execute

        expect(result).to be_success
        expect(result.keys).to eq([:number])
      end
    end
  end
end
