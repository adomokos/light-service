module LightService
  class Localizer
    def failure(message_or_key, action_class)
      if message_or_key.is_a?(Symbol)
        translate(message_or_key, action_class, type: :failure)
      else
        message_or_key
      end
    end

    def success(message_or_key, action_class)
      if message_or_key.is_a?(Symbol)
        translate(message_or_key, action_class, type: :success)
      else
        message_or_key
      end
    end

    def translate(key, action_class, options={})
      type = options.delete(:type)

      scope = i18n_scope_from_class(action_class, type)
      I18n.t(key, scope: scope)
    end

    private

    def i18n_scope_from_class(action_class, type)
      "#{action_class.name.underscore}.light_service.#{type.to_s.pluralize}"
    end
  end
end
