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
      def expects(*args)
        @_expected_keys ||= []
        @_expected_keys.concat(args)
      end

      def promises(*args)
        @_promised_keys ||= []
        @_promised_keys.concat(args)
      end

      def expected_keys
        @_expected_keys ||= []
      end

      def promised_keys
        @_promised_keys ||= []
      end

      # rubocop:disable Metrics/MethodLength
      def executed
        define_singleton_method :execute do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?

          # Store the action within the context
          action_context.current_action = self

          Context::KeyVerifier.verify_keys(action_context, self) do
            begin
              action_context.define_accessor_methods_for_keys(all_keys)

              yield(action_context)
            rescue => e
              raise e unless LightService::Configuration.capture_errors
              raise FailWithRollbackError if e.is_a?(FailWithRollbackError)
              action_context.raised_error = e
              action_context.errored_action = self
              action_context.fail!
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

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
        expected_keys + promised_keys
      end
    end
  end
end
