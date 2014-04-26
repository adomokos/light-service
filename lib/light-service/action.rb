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

      def executed
        define_singleton_method "execute" do |context = {}|
          action_context = create_action_context(context)
          return action_context if stop_processing?(action_context)

          ContextKeyVerifier.verify_expected_keys_are_in_context(action_context, @_expected_keys)

          define_expectations_readers(context)
          define_promises_accessors(context)

          yield(action_context)

          set_promises_in_context(action_context)
          ContextKeyVerifier.verify_promised_keys_are_in_context(action_context, @_promised_keys)
        end
      end

      private

      def create_action_context(context)
        if context.is_a? ::LightService::Context
          return context
        end

        LightService::Context.make(context)
      end

      def define_expectations_readers(context)
        context.keys.each do |key|
          define_singleton_method key do
            context.fetch(key)
          end
        end
      end

      def define_promises_accessors(context)
        return unless @_promised_keys
        @_promised_keys.each do |key|
          instance_variable_set("@#{key}", VALUE_NOT_SET)
          self.class.send(:attr_accessor, key)
        end
      end

      def set_promises_in_context(context)
        return unless @_promised_keys
        @_promised_keys.each do |key|
          value = instance_variable_get("@#{key}")
          next if value == VALUE_NOT_SET
          context[key] = value
        end
      end

      def stop_processing?(context)
        context.failure? || context.skip_all?
      end

      VALUE_NOT_SET = "___value_was_not_set___"
    end

  end
end
