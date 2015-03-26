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
        action = context.current_action

        verify_keys_are_in_context(context, action.expected_keys) do |not_found_keys|
          error_message = "expected #{format_keys(not_found_keys)} to be in the context during #{action}"

          Configuration.logger.error error_message
          fail ExpectedKeysNotInContextError, error_message
        end
      end

      def verify_promised_keys_are_in_context(context)
        return context if context.failure?

        action = context.current_action

        verify_keys_are_in_context(context, action.promised_keys) do |not_found_keys|
          error_message = "promised #{format_keys(not_found_keys)} to be in the context during #{action}"

          Configuration.logger.error error_message
          fail PromisedKeysNotInContextError, error_message
        end
      end

      def verify_reserved_keys_are_not_in_context(context)
        action = context.current_action

        violated_keys = (action.promised_keys + action.expected_keys) & reserved_keys

        if violated_keys.any?
          error_message = "promised or expected keys cannot be a reserved key: [#{format_keys(violated_keys)}]"

          Configuration.logger.error error_message
          fail ReservedKeysInContextError, error_message
        end
      end

      def verify_keys_are_in_context(context, keys)
        keys ||= context.keys

        not_found_keys = keys - context.keys
        unless not_found_keys.empty?
          yield not_found_keys
        end

        context
      end

      def format_keys(keys)
        keys.map { |k| ":#{k}"}.join(', ')
      end

      def reserved_keys
        [:message, :error_code, :current_action]
      end
    end
  end
end; end
