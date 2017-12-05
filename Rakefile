require "bundler/gem_tasks"

require "rubygems"
require "bundler/setup"

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task(:default).clear
task :default => %i[spec rubocop]
