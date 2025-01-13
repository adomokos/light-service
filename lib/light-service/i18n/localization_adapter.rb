module LightService
  module I18n
    class LocalizationAdapter
      def failure(message_or_key, action_class, options = {})
        find_translated_message(message_or_key,
                                action_class,
                                options.merge(:type => :failure))
      end

      def success(message_or_key, action_class, options = {})
        find_translated_message(message_or_key,
                                action_class,
                                options.merge(:type => :success))
      end

      private

      def find_translated_message(message_or_key,
                                  action_class,
                                  options)
        if message_or_key.is_a?(Symbol)
          translate(message_or_key, action_class, options)
        else
          message_or_key
        end
      end

      def translate(key, action_class, options = {})
        type = options.delete(:type)

        scope = i18n_scope_from_class(action_class, type)
        options[:scope] = scope

        ::I18n.t(key, **options)
      end

      def i18n_scope_from_class(action_class, type)
        "#{action_class.name.underscore}.light_service.#{type.to_s.pluralize}"
      end
    end
  end
end
