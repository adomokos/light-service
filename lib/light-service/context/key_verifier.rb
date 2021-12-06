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
        ExpectedValidatedKeysVerifier.new(context, action).verify

        block.call

        PromisedKeyVerifier.new(context, action).verify
        PromisedValidatedKeysVerifier.new(context, action).verify
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
      # rubocop:disable Lint/MissingSuper
      def initialize(context_data)
        @context = LightService::Context.make(context_data)
      end
      # rubocop:enable Lint/MissingSuper

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

    class ExpectedValidatedKeysVerifier < KeyVerifier
      def type_name
        "expected"
      end

      def keys
        action.options.filter { |_k, v| v.dig(:expects, :validates) }.keys
      end

      def error_to_throw
        InvalidKeysError
      end

      def error_message
        if ActiveSupport::VERSION::MAJOR >= 6
          <<~ERR
            #{action.name}:
            #{@errors.map { |e| "#{e.attribute}: #{e.message}" }.join("\n").indent(2)}
          ERR
        else
          str = []
          @errors.each { |attr, message| str << "#{attr}: #{message}" }
          <<~ERR
            #{action.name}:
            #{str.join("\n").indent(2)}
          ERR
        end
      end

      def throw_error_predicate(keys)
        return false if keys.nil? || keys == []

        validator = Validator.new(keys, action, context, :expects)
        validator.validate
        @errors = validator.errors

        return @errors.any?
      end
    end

    class PromisedValidatedKeysVerifier < KeyVerifier
      def type_name
        "promised"
      end

      def keys
        action.options.filter { |_k, v| v.dig(:promises, :validates) }.keys
      end

      def error_to_throw
        InvalidKeysError
      end

      def error_message
        if ActiveSupport::VERSION::MAJOR >= 6
          <<~ERR
            #{action.name}:
            #{@errors.map { |e| "#{e.attribute}: #{e.message}" }.join("\n").indent(2)}
          ERR
        else
          str = []
          @errors.each { |attr, message| str << "#{attr}: #{message}" }
          <<~ERR
            #{action.name}:
            #{@errors.map { |attr, message| "#{attr}: #{message}" }.join("\n").indent(2)}
          ERR
        end
      end

      def throw_error_predicate(keys)
        return false if keys.nil? || keys == []

        validator = Validator.new(keys, action, context, :promises)
        validator.validate
        @errors = validator.errors

        return @errors.any?
      end
    end
  end
end
