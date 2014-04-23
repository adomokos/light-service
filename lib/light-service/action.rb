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
          return action_context if stop_processing?(action_context)

          ContextKeyVerifier.verify_expected_keys_are_in_context(action_context, self.expected_keys)

          define_expectation_accessors(context)

          yield(action_context)

          ContextKeyVerifier.verify_promised_keys_are_in_context(action_context, self.promised_keys)
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
        context.keys.map do |key|
          define_singleton_method key do
            context.fetch(key)
          end
        end
      end

      def stop_processing?(context)
        context.failure? || context.skip_all?
      end
    end

  end
end
