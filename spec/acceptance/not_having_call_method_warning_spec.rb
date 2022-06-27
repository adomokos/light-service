require 'spec_helper'
require 'test_doubles'

describe "Organizer should invoke with/reduce from a call method" do
  context "when the organizer does not have a `call` method" do
    it "gives warning" do
      class OrganizerWithoutCallMethod
        extend LightService::Organizer

        def self.do_something
          reduce([])
        end
      end
      expect { OrganizerWithoutCallMethod.do_something }.to warn_with(
        StructuredWarnings::DeprecatedMethodWarning,
        /^The <OrganizerWithoutCallMethod> class is an organizer/
      )
    end
  end

  context "when the organizer has the `call` method" do
    it "does not issue a warning" do
      class OrganizerWithCallMethod
        extend LightService::Organizer

        def self.call
          reduce([])
        end
      end

      expect { OrganizerWithCallMethod.call }.not_to warn_with(
        StructuredWarnings::DeprecatedMethodWarning
      )
    end
  end
end
