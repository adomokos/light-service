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
        expected_keys.concat(args)
      end

      def promises(*args)
        promised_keys.concat(args)
      end

      def expected_keys
        @expected_keys ||= []
      end

      def promised_keys
        @promised_keys ||= []
      end

      def executed(*_args, &block)
        define_singleton_method :execute do |context = Context.make|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?

          # Store the action within the context
          action_context.current_action = self

          Context::KeyVerifier.verify_keys(action_context, self) do
            action_context.define_accessor_methods_for_keys(all_keys)

            catch(:jump_when_failed) do
              call_before_action(action_context)

              execute_action(action_context, &block)

              # Reset the stored action in case it was changed downstream
              action_context.current_action = self
              call_after_action(action_context)
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

      def execute_action(context)
        if around_action_context?(context)
          context.around_actions.call(context) do
            yield(context)
            context
          end
        else
          yield(context)
        end
      end

      def create_action_context(context)
        return context if context.is_a? LightService::Context

        LightService::Context.make(context)
      end

      def all_keys
        expected_keys + promised_keys
      end

      def call_before_action(context)
        invoke_callbacks(context[:_before_actions], context)
      end

      def call_after_action(context)
        invoke_callbacks(context[:_after_actions], context)
      end

      def invoke_callbacks(callbacks, context)
        return context unless callbacks

        callbacks.each do |cb|
          cb.call(context)
        end

        context
      end

      def around_action_context?(context)
        context.instance_of?(Context) &&
          context.around_actions.respond_to?(:call)
      end
    end
  end
end
