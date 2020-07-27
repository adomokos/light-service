require_relative './generator_utils'

module LightService
  module Generators
    class ActionGenerator < Rails::Generators::Base
      include GeneratorUtils

      argument :name, :type => :string
      argument :keys,
               :type => :hash,
               :default => { "expects" => '', "promises" => '' },
               :banner => "expects:one,thing promises:something,else"

      class_option :dir,
                   :type => :string,
                   :default => "actions",
                   :desc => "Path to write actions to"

      class_option :tests,
                   :type => :boolean,
                   :default => true,
                   :desc => "Generate tests (currently only RSpec supported)"

      class_option :roll_back,
                   :type => :boolean,
                   :default => true,
                   :desc => "Add a roll back block"

      source_root File.expand_path('templates', __dir__)

      desc <<~DESCRIPTION
        Description:
          Will create the boilerplate for an action. Pass it an action name, e.g.
            foo_bar, or FooBar   - will create FooBar in app/actions/foo_bar.rb
            foo/bar, or Foo::Bar - will create Foo::Bar in app/actions/foo/bar.rb

        Expects & Promises:
          Specify a list of expected context keys by passing expects and a comma separated
          list of keys. Adds keys to the `expects` list, creates convenience variables in
          the action, and generates a stub context in generated specs.

            expects:foo,bar,baz

          Specify promised context keys in the same manner as 'expects' above. This adds
          keys to the `promises` list, and creates stub expectations in generated specs.

            promises:quux,quark

        Options:
          Skip rspec test creation with --no-tests
          Skip ActionRollback creation with --no-roll-back
          Write actions to a specified dir with --dir="services". Default is "actions" in app/actions

        Full Example:
          rails g light_service:action My::Awesome::Action expects:foo,bar promises:baz,qux
      DESCRIPTION

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def create_action
        gen_vals = create_required_gen_vals_from(name)

        @module_path     = gen_vals[:module_path]
        @class_name      = gen_vals[:class_name]
        @full_class_name = gen_vals[:full_class_name]
        @expects         = keys["expects"].to_s.downcase.split(',')
        @promises        = keys["promises"].to_s.downcase.split(',')

        file_name = gen_vals[:file_name]
        file_path = gen_vals[:file_path]

        root_dir    = options.dir.downcase
        action_dir  = File.join('app', root_dir, *file_path)
        action_file = "#{action_dir}/#{file_name}"

        make_nested_dir(action_dir)
        template("action_template.erb", action_file)

        return unless must_gen_tests?

        spec_dir       = File.join('spec', root_dir, *file_path)
        spec_file_name = gen_vals[:spec_file_name]
        spec_file      = "#{spec_dir}/#{spec_file_name}"

        make_nested_dir(spec_dir)
        template("action_spec_template.erb", spec_file)
      end
      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize
    end
  end
end
