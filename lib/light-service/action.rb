require 'active_support/deprecation'

module LightService
  module Action
    def self.extended(base_class)
      base_class.extend Macros
    end

    def self.included(base_class)
      msg = "including LightService::Action is deprecated. " \
            "Please use `extend LightService::Action` instead"
      ActiveSupport::Deprecation.warn(msg)
      base_class.extend Macros
    end

    module Macros
      def expects(*args, maybe: [])
        expected_keys.concat(args)
        maybe_keys.concat(Array(maybe))

        # The WithReducerLogDecorator (and maybe other things) rely on the
        # expects method returning the list of expected keys.
        expected_keys + maybe_keys
      end

      def promises(*args)
        promised_keys.concat(args)
      end

      def expected_keys
        @_expected_keys ||= []
      end

      def promised_keys
        @_promised_keys ||= []
      end

      def maybe_keys
        @_maybe_keys ||= []
      end

      def executed
        define_singleton_method :execute do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?

          # Store the action within the context
          action_context.current_action = self

          Context::KeyVerifier.verify_keys(action_context, self) do
            action_context.define_accessor_methods_for_keys(all_keys)

            catch(:jump_when_failed) do
              yield(action_context)
            end
          end
        end
      end

      def rolled_back
        msg = "`rolled_back` macro can not be invoked again"
        raise msg if respond_to?(:rollback)

        define_singleton_method :rollback do |context = {}|
          yield(context)

          context
        end
      end

      private

      def create_action_context(context)
        return context if context.is_a? LightService::Context

        LightService::Context.make(context)
      end

      def all_keys
        expected_keys + promised_keys + maybe_keys
      end
    end
  end
end
