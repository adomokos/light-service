class LightService::Context::Validator
  include ::ActiveModel::Validations

  attr_reader :action, :context

  def initialize(validated_keys, action, context)
    @action = action
    @context = context

    (context.keys & validated_keys).map do |key|
      class_eval { attr_reader key }
      eval_validators(key, action, context)
      instance_variable_set("@#{key}", context[key])
    end
  end

  def eval_validators(key, action, context)
    class_eval do
      if (expected = action.options.dig(key, :validates, :class_name))
        validate ":class_name_validator_#{key}".to_sym

        define_method ":class_name_validator_#{key}" do
          actual = context[key].class

          return if expected == actual

          errors.add(
            :class_name,
            "must be an instance of #{expected}, got #{actual}"
          )
        end
      elsif (expected = action.options.dig(key, :validates, :class))
        validate ":class_validator_#{key}".to_sym

        define_method ":class_validator_#{key}" do
          actual = context[key]

          return if actual.is_a?(expected)

          errors.add(
            :class_name,
            "must be an instance of #{expected}, got #{actual}"
          )
        end
      else
        validates key, action.options[key][:validates]
      end
    end
  end
end