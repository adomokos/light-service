require 'spec_helper'
require 'generator_spec'

require_relative '../../../lib/generators/light_service/action_generator.rb'
require_relative './full_generator_test_blobs'

include FullGeneratorTestBlobs

describe LightService::Generators::ActionGenerator, type: :generator do
  destination File.expand_path("../tmp", __FILE__)

  before(:all) do
    prepare_destination
    run_generator
  end

  context "when generating a simple action" do
    arguments %w(my_action)

    specify do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "actions" do
            file "my_action.rb" do
              contains simple_action_blob
            end
          end
        end

        directory "spec" do
          directory "actions" do
            file "my_action_spec.rb" do
              contains simple_action_spec_blob
            end
          end
        end
      }
    end
  end
end
