module LightService
  class ExpectedKeysNotInContextError < StandardError; end
  class PromisedKeysNotInContextError < StandardError; end

  class ContextKeyVerifier
    class << self
      def verify_expected_keys_are_in_context(context, expected_keys)
        verify_keys_are_in_context(context, expected_keys) do |not_found_keys|
          fail ExpectedKeysNotInContextError, "expected #{format_keys(not_found_keys)} to be in the context"
        end
      end

      def verify_promised_keys_are_in_context(context, promised_keys)
        verify_keys_are_in_context(context, promised_keys) do |not_found_keys|
          fail PromisedKeysNotInContextError, "promised #{format_keys(not_found_keys)} to be in the context"
        end
      end

      private

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
    end
  end
end
