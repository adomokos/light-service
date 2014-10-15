require "spec_helper"
require "test_doubles"

class TestsLocalizationAdapter
  extend LightService::Organizer

  def self.with_message(pass_or_fail, message_or_key, i18n_options={})
    with({
      pass_or_fail: pass_or_fail,
      message_or_key: message_or_key,
      i18n_options: i18n_options
    }).reduce(TestsLocalizationInvocationOptionsAction)
  end
end

class TestsLocalizationInvocationOptionsAction
  include LightService::Action
  expects :pass_or_fail, :message_or_key, :i18n_options

  executed do |context|
    if context.pass_or_fail == true
      context.succeed!(context.message_or_key, context.i18n_options)
    else
      context.fail!(context.message_or_key, context.i18n_options)
    end
  end
end

def pass_with(message_or_key, i18n_options={})
  TestsLocalizationAdapter.with_message(true, message_or_key, i18n_options)  
end

def fail_with(message_or_key, i18n_options={})
  TestsLocalizationAdapter.with_message(false, message_or_key, i18n_options)  
end

describe "Localization Adapter" do

  before do
    I18n.backend.store_translations(:en, {
      tests_localization_invocation_options_action: {
        light_service: {
          failures: {
            some_failure_reason: "This has failed",
            failure_with_interpolation: "Failed with %{reason}"
          },
          successes: {
            some_success_reason: "This has passed",
            success_with_interpolation: "Passed with %{reason}"
          }
        }
      }
    })
  end

  describe "passing a simple string message" do
    describe "by failing the context" do
      it "returns the string" do
        result = fail_with("string message")

        expect(result).to be_failure
        expect(result.message).to eq("string message")
      end
    end

    describe "by passing the context" do
      it "returns the string" do
        result = pass_with("string message")

        expect(result).to be_success
        expect(result.message).to eq("string message")
      end
    end
  end

  describe "passing a Symbol" do
    describe "by failing the context" do
      it "performs a translation" do
        result = fail_with(:some_failure_reason)

        expect(result).to be_failure
        expect(result.message).to eq("This has failed")
      end
    end

    describe "by passing the contenxt" do
      it "performs a translation" do
        result = pass_with(:some_success_reason)

        expect(result).to be_success
        expect(result.message).to eq("This has passed")
      end
    end
  end

  describe "passing a Symbol with interpolation variables" do
    describe "by failing the context" do
      it "performs a translation with interpolation" do
        result = fail_with(:failure_with_interpolation, reason: "bad account")

        expect(result).to be_failure
        expect(result.message).to eq("Failed with bad account")
      end
    end

    describe "by passing the context" do
      it "performs a translation with interpolation" do
        result = pass_with(:success_with_interpolation, reason: "account in good standing")

        expect(result).to be_success
        expect(result.message).to eq("Passed with account in good standing")
      end
    end
  end

end
