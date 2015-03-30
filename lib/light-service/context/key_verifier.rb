module LightService; class Context
  class KeyVerifier
    class << self
      def verify_keys(context, &block)
        verify_reserved_keys_are_not_in_context(context)
        verify_expected_keys_are_in_context(context)

        block.call

        verify_promised_keys_are_in_context(context)
      end

      private

      def verify_expected_keys_are_in_context(context)
        return context if context.failure?

        action = context.current_action
        expected_keys = action.expected_keys

        unless are_all_keys_in_context?(context, expected_keys)
          error_message = "expected #{format_keys(keys_not_found(context, expected_keys))} to be in the context during #{action}"

          Configuration.logger.error error_message
          fail ExpectedKeysNotInContextError, error_message
        end

        context
      end

      def verify_promised_keys_are_in_context(context)
        return context if context.failure?

        action = context.current_action
        promised_keys = action.promised_keys

        unless are_all_keys_in_context?(context, promised_keys)
          error_message = "promised #{format_keys(keys_not_found(context, promised_keys))} to be in the context during #{action}"

          Configuration.logger.error error_message
          fail PromisedKeysNotInContextError, error_message
        end

        context
      end

      def verify_reserved_keys_are_not_in_context(context)
        return context if context.failure?

        action = context.current_action
        violated_keys = (action.promised_keys + action.expected_keys) & reserved_keys

        if violated_keys.any?
          error_message = "promised or expected keys cannot be a reserved key: [#{format_keys(violated_keys)}]"

          Configuration.logger.error error_message
          fail ReservedKeysInContextError, error_message
        end
      end

      def are_all_keys_in_context?(context, keys)
        not_found_keys = keys_not_found(context, keys)
        !not_found_keys.any?
      end

      def keys_not_found(context, keys)
        keys ||= context.keys
        keys - context.keys
      end

      def format_keys(keys)
        keys.map { |k| ":#{k}"}.join(', ')
      end

      def reserved_keys
        [:message, :error_code, :current_action].freeze
      end
    end
  end
end; end
