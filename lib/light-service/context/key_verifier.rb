module LightService
  class Context
    class KeyVerifier
      attr_reader :context, :action

      def initialize(context, action)
        @context = context
        @action = action
      end

      def are_all_keys_in_context?(keys)
        not_found_keys = keys_not_found(keys)
        !not_found_keys.any?
      end

      def keys_not_found(keys)
        keys ||= context.keys
        keys - context.keys
      end

      def format_keys(keys)
        keys.map { |k| ":#{k}" }.join(', ')
      end

      def error_message
        "#{type_name} #{format_keys(keys_not_found(keys))} " \
        "to be in the context during #{action}"
      end

      def throw_error_predicate(_keys)
        raise NotImplementedError, 'Sorry, you have to override length'
      end

      def verify
        return context if context.failure?

        if throw_error_predicate(keys)
          Configuration.logger.error error_message
          raise error_to_throw, error_message
        end

        context
      end

      def self.verify_keys(context, action, &block)
        ReservedKeysVerifier.new(context, action).verify
        ExpectedKeyVerifier.new(context, action).verify
        accessed_keys = context.with_key_logging do
          block.call
        end
        PromisedKeyVerifier.new(context, action).verify
        ExpectedKeyUsedVerifier.new(context, action, accessed_keys).verify
      end
    end

    class ExpectedKeyUsedVerifier < KeyVerifier
      def initialize(context, action, accessed_keys)
        @accessed_keys = accessed_keys
        super(context, action)
      end

      def keys
        action.expected_keys - @accessed_keys
      end

      def error_to_throw
        ExpectedKeysNotUsedError
      end

      def throw_error_predicate(keys)
        keys.any?
      end

      def error_message
        "Expected keys [#{format_keys(keys)}] to be used during #{action}"
      end
    end

    class ExpectedKeyVerifier < KeyVerifier
      def type_name
        "expected"
      end

      def keys
        action.expected_keys
      end

      def error_to_throw
        ExpectedKeysNotInContextError
      end

      def throw_error_predicate(keys)
        !are_all_keys_in_context?(keys)
      end
    end

    class PromisedKeyVerifier < KeyVerifier
      def type_name
        "promised"
      end

      def keys
        action.promised_keys
      end

      def error_to_throw
        PromisedKeysNotInContextError
      end

      def throw_error_predicate(keys)
        !are_all_keys_in_context?(keys)
      end
    end

    class ReservedKeysVerifier < KeyVerifier
      def violated_keys
        (action.promised_keys + action.expected_keys) & reserved_keys
      end

      def error_message
        "promised or expected keys cannot be a " \
        "reserved key: [#{format_keys(violated_keys)}]"
      end

      def keys
        violated_keys
      end

      def error_to_throw
        ReservedKeysInContextError
      end

      def throw_error_predicate(keys)
        keys.any?
      end

      def reserved_keys
        [:message, :error_code, :current_action].freeze
      end
    end
  end
end
