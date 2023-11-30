require 'spec_helper'
require 'test_doubles'

describe "Organizer should invoke with/reduce from a call method" do
  context "when the organizer does not have a `call` method" do
    it "gives warning" do
      expect(LightService)
        .to receive(:deprecation_warning)
        .with(/^The <OrganizerWithoutCallMethod> class is an organizer/)

      class OrganizerWithoutCallMethod
        extend LightService::Organizer

        def self.do_something
          reduce([])
        end
      end

      OrganizerWithoutCallMethod.do_something
    end
  end

  context "when the organizer has the `call` method" do
    it "does not issue a warning" do
      expect(ActiveSupport::Deprecation)
        .not_to receive(:warn)

      class OrganizerWithCallMethod
        extend LightService::Organizer

        def self.call
          reduce([])
        end
      end

      OrganizerWithCallMethod.call
    end
  end
end
