$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

if ENV['RUN_COVERAGE_REPORT']
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.start do
    add_filter 'vendor/'
    add_filter %r{^/spec/}

    formatter SimpleCov::Formatter::CoberturaFormatter
  end
  SimpleCov.minimum_coverage_by_file 90
end

require 'light-service'
require 'light-service/testing'
require 'ostruct'
require 'pry'
require 'support'
require 'test_doubles'
require 'stringio'
require 'fileutils'
require 'generator_spec'

I18n.enforce_available_locales = true
