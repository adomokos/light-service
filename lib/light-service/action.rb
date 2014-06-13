module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      def expects(*args)
        @_expected_keys = args
      end

      def promises(*args)
        @_promised_keys = args
      end

      def expected_keys
        @_expected_keys
      end

      def promised_keys
        @_promised_keys
      end

      def executed
        define_singleton_method "execute" do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?
          action = self

          Context::KeyVerifier.verify_expected_keys_are_in_context(action_context, action)

          action_context.define_accessor_methods_for_keys(expected_keys)
          action_context.define_accessor_methods_for_keys(promised_keys)

          yield(action_context)

          Context::KeyVerifier.verify_promised_keys_are_in_context(action_context, action)
        end
      end

      private

      def create_action_context(context)
        if context.is_a? ::LightService::Context
          return context
        end

        LightService::Context.make(context)
      end

    end
  end
end
