require 'spec_helper'

require_relative '../../../lib/generators/light_service/action_generator.rb'
require_relative './full_generator_test_blobs'

include FullGeneratorTestBlobs

describe LightService::Generators::ActionGenerator, :type => :generator do
  destination File.expand_path('tmp', __dir__)

  context "when generating an advanced action" do
    before(:all) do
      prepare_destination
      run_generator
    end

    after(:all) do
      FileUtils.rm_rf destination_root
    end

    arguments %w[my/fancy/action expects:foo,bar promises:baz,qux --no-roll-back --dir=services]

    specify do
      expect(destination_root).to have_structure {
        directory "app/services/my/fancy" do
          file "action.rb" do
            contains advanced_action_blob
          end
        end

        directory "spec/services/my/fancy" do
          file "action_spec.rb" do
            contains advanced_action_spec_blob
          end
        end
      }
    end
  end
end
