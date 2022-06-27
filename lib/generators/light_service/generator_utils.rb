module LightService
  module Generators
    module GeneratorUtils
      def make_nested_dir(dir)
        FileUtils.mkdir_p(dir)
      end

      def supported_test_frameworks
        %i[rspec]
      end

      def test_framework_supported?
        supported_test_frameworks.include? test_framework
      end

      # Don't know a better way to get to this value, unfortunately.
      def test_framework
        # Rails.application.config.generators.options[:rails][:test_framework]
        # When/if Minitest is supported, this will need to be updated to detect
        # the selected test framework, and switch templates accordingly
        :rspec
      end

      def must_gen_tests?
        options.tests? && test_framework_supported?
      end

      def create_required_gen_vals_from(name)
        # Not using dry-inflector here, because generators are used only
        # within Rails project thus we can relay on ActiveSupport presence.
        # Maybe plan to split LightService::Generators into a separate
        # gem (e.g.: light_service-rails-generators)
        path_parts = name.underscore.split('/')

        {
          :path_parts => path_parts,
          :file_path => path_parts.reverse.drop(1).reverse,
          :module_path => path_parts.reverse.drop(1).reverse.join('/').classify,
          :class_name => path_parts.last.classify,
          :file_name => "#{path_parts.last}.rb",
          :spec_file_name => "#{path_parts.last}_spec.rb",
          :full_class_name => name.classify
        }
      end
    end
  end
end
