module LightService
  class LocalizationAdapter
    def failure(message_or_key, action_class, options = {})
      find_translated_message(message_or_key,
                              action_class.to_s.underscore,
                              options.merge(:type => :failures))
    end

    def success(message_or_key, action_class, options = {})
      find_translated_message(message_or_key,
                              action_class.to_s.underscore,
                              options.merge(:type => :successes))
    end

    private

    def find_translated_message(message_or_key, action_class, options)
      if message_or_key.is_a?(Symbol)
        LightService::LocalizationMap.instance.dig(
          LightService::Configuration.locale,
          action_class.to_sym,
          :light_service,
          options[:type],
          message_or_key
        )
      else
        message_or_key
      end
    end
  end
end
