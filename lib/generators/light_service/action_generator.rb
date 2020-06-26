require_relative './generator_utils'

module LightService
  module Generators
    class ActionGenerator < Rails::Generators::Base
      include GeneratorUtils

      argument :name, type: :string
      argument :keys, type: :hash, default: { "expects"  => '', "promises" => '' }, banner: "expects:one,thing promises:something,else"

      class_option :dir,       type: :string,  default: "actions", desc: "Path to write actions to"
      class_option :tests,     type: :boolean, default: true,      desc: "Generate test files (currently only RSpec supported)"
      class_option :roll_back, type: :boolean, default: true,      desc: "Add a roll back block"

      source_root File.expand_path('../templates', __FILE__)

      desc <<~DESCRIPTION
        Description:
          Will create the boilerplate for an action. Pass it an action name, e.g.
            thing_doer, or ThingDoer   - will create ThingDoer in app/actions/thing_doer.rb
            thing/doer, or Thing::Doer - will create Thing::Doer in app/actions/thing/doer.rb

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

      def create_action
        path_parts = name.underscore.split('/')

        action_root = options.dir.downcase
        file_name   = "#{path_parts.last}.rb"
        file_path   = path_parts.reverse.drop(1).reverse

        @module_path = path_parts.reverse.drop(1).reverse.join('/').classify
        @class_name  = path_parts.last.classify

        @expects  = keys["expects"].to_s.downcase.split(',')
        @promises = keys["promises"].to_s.downcase.split(',')

        action_dir  = Rails.root.join('app', action_root, *file_path)
        action_file = action_dir + file_name

        make_nested_dir(action_dir)
        template("action_template.erb", action_file)

        if must_gen_tests?
          spec_dir       = Rails.root.join('spec', action_root, *file_path)
          spec_file_name = "#{path_parts.last}_spec.rb"
          spec_file      = spec_dir + spec_file_name

          @full_class_name = name.classify

          make_nested_dir(spec_dir)
          template("action_spec_template.erb", spec_file)
        end
      end
    end
  end
end
