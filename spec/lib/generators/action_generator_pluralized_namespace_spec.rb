require 'spec_helper'

require_relative '../../../lib/generators/light_service/action_generator'
require_relative './full_generator_test_blobs'

describe LightService::Generators::ActionGenerator, :type => :generator do
  destination File.expand_path('tmp', __dir__)

  context "when generating a pluralized action in a pluralized namespace" do
    before(:all) do
      prepare_destination
      run_generator
    end

    after(:all) do
      FileUtils.rm_rf destination_root
    end

    arguments %w[users/fetch_users]

    specify do
      expect(destination_root).to(have_structure do
        directory "app/actions/users" do
          file "fetch_users.rb" do
            contains FullGeneratorTestBlobs.namespaced_pluralized_action_blob
          end
        end

        directory "spec/actions/users" do
          file "fetch_users_spec.rb" do
            contains FullGeneratorTestBlobs.namespaced_pluralized_action_spec_blob
          end
        end
      end)
    end
  end
end
