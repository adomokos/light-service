module LightService
  class LocalizationAdapter
    # Passing `options` as third param is supported by signature
    # but it's not used by this built-in localization adapter
    # at the moment.
    # `options` could be useful for alternative or custom
    # adapters - that may want to inherit from this one
    # overriding something into the final implementation -,
    # thus we provide a uniformed signature
    def failure(message_or_key, action_class, _options = nil)
      find_translated_message(message_or_key,
                              action_class.to_s.underscore,
                              :failures)
    end

    # Passing `options` as third param is supported by signature
    # but it's not used by this built-in localization adapter
    # at the moment.
    # `options` could be useful for alternative or custom
    # adapters - that may want to inherit from this one
    # overriding something into the final implementation -,
    # thus we provide a uniformed signature
    def success(message_or_key, action_class, _options = nil)
      find_translated_message(message_or_key,
                              action_class.to_s.underscore,
                              :successes)
    end

    private

    def find_translated_message(message_or_key, action_class, type)
      if message_or_key.is_a?(Symbol)
        LightService::LocalizationMap.instance.dig(
          LightService::Configuration.locale,
          action_class.to_sym,
          :light_service,
          type,
          message_or_key
        )
      else
        message_or_key
      end
    end
  end
end
