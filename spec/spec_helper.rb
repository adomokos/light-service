$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'light-service'
require 'light-service/testing'
require 'ostruct'
require 'active_support/core_ext/string'
require 'pry'

I18n.enforce_available_locales = true
