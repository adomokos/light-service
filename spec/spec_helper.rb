$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'light-service'
require 'ostruct'
require 'rspec/its'
require 'active_support/core_ext/string'

I18n.enforce_available_locales = true
