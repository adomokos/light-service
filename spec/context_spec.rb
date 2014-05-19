require "spec_helper"

module LightService
  describe Context do

    describe "can be made" do
      context "with no arguments" do
        subject { Context.make }
        it { should be_success }
        its(:message) { should be_empty }
      end

      context "with a hash" do
        it "has the hash values" do
          context = Context.make(:one => 1)
          expect(context[:one]).to eq(1)
        end
      end

      context "with FAILURE" do
        it "is failed" do
          context = Context.new({}, ::LightService::Outcomes::FAILURE, '')
          expect(context).to be_failure
        end
      end
    end

    describe "can't be made" do
      specify "with invalid parameters" do
        expect{Context.make([])}.to raise_error(ArgumentError)
      end
    end

    it "can be asked for success?" do
      context = Context.new({}, ::LightService::Outcomes::SUCCESS)
      expect(context.success?).to be_true
    end

    it "can be asked for failure?" do
      context = Context.new({}, ::LightService::Outcomes::FAILURE)
      expect(context.failure?).to be_true
    end

    it "can be asked for skip_all?" do
      context = Context.make
      context.skip_all!
      expect(context.skip_all?).to be_true
    end

    it "can be pushed into a SUCCESS state" do
      context = Context.make
      context.succeed!("a happy end")
      expect(context).to be_success
    end

    it "can be pushed into a SUCCESS state without a message" do
      context = Context.make
      context.succeed!
      expect(context).to be_success
      expect(context.message).to be_nil
    end

    it "can be pushed into a FAILURE state" do
      context = Context.make
      context.fail!("a sad end", 10005)
      expect(context).to be_failure
    end

    it "can be pushed into a FAILURE state without a message" do
      context = Context.make
      context.fail!(nil, 10005)
      expect(context).to be_failure
      expect(context.message).to be_nil
    end

    it "can be pushed into a FAILURE state without an error code" do
      context = Context.make
      context.fail!("a sad end")
      expect(context).to be_failure
      expect(context.error_code).to be_nil
    end

    it "can be pushed into a FAILURE state without an error code or message" do
      context = Context.make
      context.fail!
      expect(context).to be_failure
      expect(context.message).to be_nil
      expect(context.error_code).to be_nil
    end

    it "can set a flag to skip all subsequent actions" do
      context = Context.make
      context.skip_all!
      expect(context).to be_skip_all
    end

    context "stopping additional processing in an action" do
      let(:context) { Context.make }

      it "flags processing to stop on failure" do
        context.fail!("on purpose")
        expect(context.stop_processing?).to be_true
      end

      it "flags processing to stop when remaining actions should be skipped" do
        context.skip_all!
        expect(context.stop_processing?).to be_true
      end
    end

  end
end
