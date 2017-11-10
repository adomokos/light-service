module LightService
  class Configuration
    class << self
      attr_accessor :capture_errors
      attr_writer :logger, :localization_adapter

      def logger
        @logger ||= _default_logger
      end

      def localization_adapter
        @localization_adapter ||= LocalizationAdapter.new
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
