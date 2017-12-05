module LightService
  class Context
    class KeyVerifier
      attr_reader :context, :action

      def initialize(context, action)
        @context = context
        @action = action
      end

      def keys_missing_from_context(keys)
        keys - context.keys
      end

      def formatted_keys
        offending_keys.map { |k| ":#{k}" }.join(', ')
      end

      def error_message
        "#{type_name} #{formatted_keys} to be in the context during #{action}"
      end

      def throw_error?
        offending_keys.any?
      end

      def verify
        return context if context.failure?
        return context unless throw_error?

        Configuration.logger.error error_message
        raise error_to_throw, error_message
      end

      def self.verify_keys(context, action, &block)
        ReservedKeysVerifier.new(context, action).verify
        ExpectedKeyVerifier.new(context, action).verify

        accessed_keys = context.execute_with_key_logging(&block)

        PromisedKeyVerifier.new(context, action).verify
        ExpectedKeyUsedVerifier.new(context, action, accessed_keys).verify
      end
    end

    class ExpectedKeyUsedVerifier < KeyVerifier
      def initialize(context, action, accessed_keys)
        @accessed_keys = accessed_keys
        super(context, action)
      end

      def offending_keys
        action.expected_keys - @accessed_keys
      end

      def error_to_throw
        ExpectedKeysNotUsedError
      end

      def error_message
        "Expected keys [#{formatted_keys}] to be used during #{action}"
      end
    end

    class ExpectedKeyVerifier < KeyVerifier
      def type_name
        "expected"
      end

      def offending_keys
        keys_missing_from_context(action.expected_keys)
      end

      def error_to_throw
        ExpectedKeysNotInContextError
      end
    end

    class PromisedKeyVerifier < KeyVerifier
      def type_name
        "promised"
      end

      def offending_keys
        keys_missing_from_context(action.promised_keys)
      end

      def error_to_throw
        PromisedKeysNotInContextError
      end
    end

    class ReservedKeysVerifier < KeyVerifier
      def error_message
        "promised or expected keys cannot be a reserved key: "\
        "[#{formatted_keys}]"
      end

      def offending_keys
        (action.promised_keys + action.expected_keys) & reserved_keys
      end

      def error_to_throw
        ReservedKeysInContextError
      end

      def reserved_keys
        %i[message error_code current_action].freeze
      end
    end
  end
end
