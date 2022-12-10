require 'spec_helper'

describe "Including is discouraged" do
  context "when including LightService::Organizer" do
    it "gives warning" do
      expected_msg = "including LightService::Organizer is deprecated. " \
                     "Please use `extend LightService::Organizer` instead"
      expect(LightService::Deprecation).to receive(:warn)
        .with(expected_msg)

      class OrganizerIncludingLS
        include LightService::Organizer
      end
    end
  end

  context "when including LightService::Action" do
    it "gives warning" do
      expected_msg = "including LightService::Action is deprecated. " \
                     "Please use `extend LightService::Action` instead"
      expect(LightService::Deprecation).to receive(:warn)
        .with(expected_msg)

      class ActionIncludingLS
        include LightService::Action
      end
    end
  end
end
