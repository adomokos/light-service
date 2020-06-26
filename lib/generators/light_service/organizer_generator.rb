module LightService
  module Generators
    class OrganizerGenerator < Rails::Generators::Base
      argument :name, type: :string

      class_option :dir,   type: :string,  default: "organizers", desc: "Path to write organizers to"
      class_option :tests, type: :boolean, default: true,         desc: "Generate test files (currently only RSpec supported)"

      source_root File.expand_path('../templates', __FILE__)

      desc <<~DESCRIPTION
        Description:
          Will create the boilerplate for an organizer. Pass it an organizer name, e.g.
            thing_maker, or ThingMaker   - will create ThingMaker in app/organizers/thing_doer.rb
            thing/maker, or Thing::Maker - will create Thing::Maker in app/organizers/thing/doer.rb

        Options:
          Skip rspec test creation with --no-tests
          Write organizers to a specified dir with --dir="workflows". Default is "organizers" in app/organizers

        Full Example:
          rails g light_service:organizer My::Awesome::Organizer
      DESCRIPTION

      def create_organzier
        path_parts = name.underscore.split('/')

        organizer_root = options.dir.downcase
        file_name      = "#{path_parts.last}.rb"
        file_path      = path_parts.reverse.drop(1).reverse

        @module_path = path_parts.reverse.drop(1).reverse.join('/').classify
        @class_name  = path_parts.last.classify

        organizer_dir  = Rails.root.join('app', organizer_root, *file_path)
        organizer_file = organizer_dir + file_name

        make_nested_dir(organizer_dir)
        template("organizer_template.erb", organizer_file)

        if must_gen_tests?
          spec_dir       = Rails.root.join('spec', organizer_root, *file_path)
          spec_file_name = "#{path_parts.last}_spec.rb"
          spec_file      = spec_dir + spec_file_name

          @full_class_name = name.classify

          make_nested_dir(spec_dir)
          template("organizer_spec_template.erb", spec_file)
        end
      end

      private

      def make_nested_dir(dir)
        FileUtils.mkdir_p(dir)
      end

      def supported_test_frameworks
        %i[rspec]
      end

      def test_framework_supported?
        supported_test_frameworks.include? test_framework
      end

      def test_framework
        # Don't know a better way to get to this value, unfortunately.
        Rails.application.config.generators.options[:rails][:test_framework]
      end

      def must_gen_tests?
        options.tests? && test_framework_supported?
      end
    end
  end
end
