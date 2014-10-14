module LightService
  class Localizer
    def failure(message_or_key, action_class, i18n_options={})
      if message_or_key.is_a?(Symbol)
        i18n_options.merge!(type: :failure)
        translate(message_or_key, action_class, i18n_options)
      else
        message_or_key
      end
    end

    def success(message_or_key, action_class, i18n_options={})
      if message_or_key.is_a?(Symbol)
        i18n_options.merge!(type: :success)
        translate(message_or_key, action_class, i18n_options)
      else
        message_or_key
      end
    end

    def translate(key, action_class, options={})
      type = options.delete(:type)

      scope = i18n_scope_from_class(action_class, type)
      options.merge!(scope: scope)

      I18n.t(key, options)
    end

    private

    def i18n_scope_from_class(action_class, type)
      "#{action_class.name.underscore}.light_service.#{type.to_s.pluralize}"
    end
  end
end
