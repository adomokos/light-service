module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      attr_reader :expected_keys, :promised_keys

      def expects(*args)
        @expected_keys = args
      end

      def promises(*args)
        @promised_keys = args
      end

      def executed
        define_singleton_method "execute" do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.failure? || action_context.skip_all?

          define_expectation_accessors(action_context)

          yield(action_context)

          action_context
        end
      end

      private

      def create_action_context(context)
        if context.respond_to? :failure?
          return context
        end

        LightService::Context.make(context)
      end

      def define_expectation_accessors(context)
        verify_expected_keys_are_in_context(context)

        context.keys.map do |key|
          define_singleton_method key do
            context.fetch(key)
          end
        end
      end

      def verify_expected_keys_are_in_context(context)
        expected_keys = self.expected_keys || context.keys

        not_found_keys = expected_keys - context.keys
        unless not_found_keys.empty?
          fail ArgumentError, "expected :#{not_found_keys} to be in the context"
        end
      end

    end

  end
end
