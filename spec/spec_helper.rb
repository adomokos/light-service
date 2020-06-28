$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

if ENV['RUN_COVERAGE_REPORT']
  require 'simplecov'

  SimpleCov.start do
    add_filter 'vendor/'
    add_filter %r{^/spec/}
  end
  SimpleCov.minimum_coverage_by_file 90

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
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
