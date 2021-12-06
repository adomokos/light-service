require 'active_model'

module LightService
  class Context
    class Validator
      include ::ActiveModel::Validations

      attr_reader :action, :context, :type

      def initialize(validated_keys, action, context, type)
        @action = action
        @context = context
        @type = type

        (context.keys & validated_keys).map do |key|
          class_eval { attr_reader key }
          eval_validators(key, action.options.dup, context, type)
          instance_variable_set("@#{key}", context[key])
        end
      end

      private

      def eval_validators(key, options, context, type)
        validations = options[key][type][:validates]
        usable_validations = validations.reject { |k, _v| k.in? %i[class_name class default] }
        class_eval do
          eval_class_name_validator(key, validations, context)
          eval_class_validator(key, validations, context)

          validates(key, usable_validations) if usable_validations.keys.any?
        end
      end

      class << self
        def eval_class_name_validator(key, validations, context)
          return unless validations[:class_name]

          expected = validations[:class_name]
          validate ":class_name_validator_#{key}".to_sym

          define_method ":class_name_validator_#{key}" do
            actual = context[key].class

            return if expected == actual

            errors.add(
              key,
              :message => "must be an instance of #{expected}, got #{actual}"
            )
          end
        end

        def eval_class_validator(key, validations, context)
          return unless validations[:class]

          expected = validations[:class]
          validate ":class_validator_#{key}".to_sym

          define_method ":class_validator_#{key}" do
            actual = context[key]

            return if actual.is_a?(expected)

            errors.add(
              key,
              :message => "must be an instance of #{expected}, got #{actual}"
            )
          end
        end
      end
    end
  end
end