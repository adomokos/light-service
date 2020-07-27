require 'spec_helper'

require_relative '../../../lib/generators/light_service/action_generator.rb'
require_relative './full_generator_test_blobs'

describe LightService::Generators::ActionGenerator, :type => :generator do
  destination File.expand_path('tmp', __dir__)

  context "when generating a simple action" do
    before(:all) do
      prepare_destination
      run_generator
    end

    after(:all) do
      FileUtils.rm_rf destination_root
    end

    arguments %w[my_action]

    specify do
      expect(destination_root).to(have_structure do
        directory "app/actions" do
          file "my_action.rb" do
            contains FullGeneratorTestBlobs.simple_action_blob
          end
        end

        directory "spec/actions" do
          file "my_action_spec.rb" do
            contains FullGeneratorTestBlobs.simple_action_spec_blob
          end
        end
      end)
    end
  end
end
