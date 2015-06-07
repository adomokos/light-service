require 'spec_helper'
require 'test_doubles'

describe "Including is discouraged" do
  context "when including LightService::Organizer" do
    it "gives warning" do
      expect(ActiveSupport::Deprecation).to receive(:warn)
                                        .with("including Lightervice::Organizer is deprecated. Please use `extend LightService::Organizer` instead")

      class OrganizerIncludingLS
        include LightService::Organizer
      end
    end
  end

  context "when including LightService::Action" do
    it "gives warning" do
      expect(ActiveSupport::Deprecation).to receive(:warn)
                                        .with("including Lightervice::Action is deprecated. Please use `extend LightService::Action` instead")

      class ActionIncludingLS
        include LightService::Action
      end
    end
  end
end
