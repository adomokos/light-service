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
