require 'spec_helper'

require_relative '../../../lib/generators/light_service/organizer_generator.rb'
require_relative './full_generator_test_blobs'

describe LightService::Generators::OrganizerGenerator, :type => :generator do
  destination File.expand_path('tmp', __dir__)

  context "when generating a simple organizer" do
    before(:all) do
      prepare_destination
      run_generator
    end

    after(:all) do
      FileUtils.rm_rf destination_root
    end

    arguments %w[my_organizer]

    specify do
      expect(destination_root).to(have_structure do
        directory "app/organizers" do
          file "my_organizer.rb" do
            contains FullGeneratorTestBlobs.simple_organizer_blob
          end
        end

        directory "spec/organizers" do
          file "my_organizer_spec.rb" do
            contains FullGeneratorTestBlobs.simple_organizer_spec_blob
          end
        end
      end)
    end
  end
end
