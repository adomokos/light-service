class LightService::Context::Validator
  include ::ActiveModel::Validations

  def initialize(validated_keys, action, context)
    (context.keys & validated_keys).map do |key|
      class_eval do
        attr_reader key

        validates key, action.options[key][:validates]
      end

      instance_variable_set("@#{key}", context[key])
    end
  end
end