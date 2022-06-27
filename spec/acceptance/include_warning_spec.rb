require 'spec_helper'
require 'structured_warnings_helper'

describe "Including is discouraged" do
  context "when including LightService::Organizer" do
    it "gives warning" do
      expected_msg = "including LightService::Organizer is deprecated. " \
                     "Please use `extend LightService::Organizer` instead"

      expect do
        class OrganizerIncludingLS
          include LightService::Organizer
        end
      end.to warn_with(StructuredWarnings::DeprecatedMethodWarning, expected_msg)
    end
  end

  context "when including LightService::Action" do
    it "gives warning" do
      expected_msg = "including LightService::Action is deprecated. " \
                     "Please use `extend LightService::Action` instead"

      expect do
        class ActionIncludingLS
          include LightService::Action
        end
      end.to warn_with(StructuredWarnings::DeprecatedMethodWarning, expected_msg)
    end
  end
end
