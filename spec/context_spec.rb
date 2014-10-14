require "spec_helper"
require 'test_doubles'

describe LightService::Context do

  let(:context) { LightService::Context.make }

  describe "can be made" do
    context "with no arguments" do
      subject { LightService::Context.make }
      it { is_expected.to be_success }
      its(:message) { should be_empty }
    end

    context "with a hash" do
      it "has the hash values" do
        context = LightService::Context.make(:one => 1)

        expect(context[:one]).to eq(1)
      end
    end

    context "with FAILURE" do
      it "is failed" do
        context = LightService::Context.new({}, ::LightService::Outcomes::FAILURE, '')

        expect(context).to be_failure
      end
    end
  end

  describe "can't be made" do
    specify "with invalid parameters" do
      expect{LightService::Context.make([])}.to raise_error(ArgumentError)
    end
  end

  it "can be asked for success?" do
    context = LightService::Context.new({}, ::LightService::Outcomes::SUCCESS)

    expect(context).to be_success
  end

  it "can be asked for failure?" do
    context = LightService::Context.new({}, ::LightService::Outcomes::FAILURE)

    expect(context).to be_failure
  end

  it "can be asked for skip_all?" do
    context.skip_all!

    expect(context.skip_all?).to be_truthy
  end

  it "can be pushed into a SUCCESS state" do
    context.succeed!("a happy end")

    expect(context).to be_success
  end

  it "can be pushed into a SUCCESS state without a message" do
    context.succeed!

    expect(context).to be_success
    expect(context.message).to be_nil
  end

  it "can be pushed into a FAILURE state without a message" do
    context.fail!

    expect(context).to be_failure
    expect(context.message).to be_nil
  end

  it "can be pushed into a FAILURE state with a message" do
    context.fail!("a sad end")

    expect(context).to be_failure
  end

  it "can be pushed into a FAILURE state with a message in an options hash" do
    context.fail!("a sad end")

    expect(context).to be_failure
    expect(context.message).to eq("a sad end")
    expect(context.error_code).to be_nil
  end

  it "can be pushed into a FAILURE state with an error code in an options hash" do
    context.fail!("a sad end", 10005)

    expect(context).to be_failure
    expect(context.message).to eq("a sad end")
    expect(context.error_code).to eq(10005)
  end

  it "uses localizer to translate failure message" do
    action_class = TestDoubles::AnAction
    expect(LightService::Configuration.localizer).to receive(:failure)
                                                 .with(:failure_reason, action_class)
                                                 .and_return("message")

    context = LightService::Context.make
    context.current_action = action_class
    context.fail!(:failure_reason)

    expect(context).to be_failure
    expect(context.message).to eq("message")
  end

  it "uses localizer to translate success message" do
    action_class = TestDoubles::AnAction
    expect(LightService::Configuration.localizer).to receive(:success)
                                                 .with(:action_passed, action_class)
                                                 .and_return("message")

    context = LightService::Context.make
    context.current_action = action_class
    context.succeed!(:action_passed)

    expect(context).to be_success
    expect(context.message).to eq("message")
  end

  it "can set a flag to skip all subsequent actions" do
    context.skip_all!

    expect(context).to be_skip_all
  end

  context "stopping additional processing in an action" do
    it "flags processing to stop on failure" do
      context.fail!("on purpose")
      expect(context.stop_processing?).to be_truthy
    end

    it "flags processing to stop when remaining actions should be skipped" do
      context.skip_all!
      expect(context.stop_processing?).to be_truthy
    end
  end

  it "can fail with FailWithRollBackError" do
    expect { context.fail_with_rollback!("roll me back") }.to \
      raise_error(LightService::FailWithRollbackError)
  end
end
