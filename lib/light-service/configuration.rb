module LightService
  class Configuration
    class << self
      attr_accessor :capture_errors
      attr_writer :logger, :localization_adapter, :locale

      def logger
        @logger ||= _default_logger
      end

      def localization_adapter
        @localization_adapter ||= if Module.const_defined?('I18n')
                                    LightService::I18n::LocalizationAdapter.new
                                  else
                                    LocalizationAdapter.new
                                  end
      end

      def locale
        @locale ||= :en
      end

      private

      def _default_logger
        logger = Logger.new("/dev/null")
        logger.level = Logger::WARN
        logger
      end
    end
  end
end
