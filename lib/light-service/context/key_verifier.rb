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
        not_found_keys.none?
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

        block.call

        PromisedKeyVerifier.new(context, action).verify
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
        %i[message error_code current_action organized_by].freeze
      end
    end

    class ReservedKeysViaOrganizerVerifier < ReservedKeysVerifier
      def initialize(context_data)
        super
        @context = LightService::Context.make(context_data)
      end

      def violated_keys
        context.keys.map(&:to_sym) & reserved_keys
      end

      def error_message
        <<~ERR
          reserved keys cannot be added to the context
          reserved key: [#{format_keys(violated_keys)}]
        ERR
      end
    end
  end
end
