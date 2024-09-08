require 'spec_helper'

RSpec.describe "skip_all! has been deprecated" do
  it "is now skip_remaining!" do
    class SkipAllDeprecatedAction
      extend LightService::Action

      executed do |ctx|
        ctx.skip_all!("No need to execute other actions.")
      end
    end

    expected_msg = "Using skip_all! has been deprecated, " \
                   "please use `skip_remaining!` instead."
    expect(LightService::Deprecation).to receive(:warn)
      .with(expected_msg)

    SkipAllDeprecatedAction.execute
  end
end
