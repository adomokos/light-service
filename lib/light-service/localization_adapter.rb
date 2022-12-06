module LightService
  class LocalizationAdapter
    def failure(message_or_key, action_class)
      find_translated_message(message_or_key,
                              action_class.to_s.underscore,
                              :failures)
    end

    def success(message_or_key, action_class)
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
