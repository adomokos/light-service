module LightService
  class Configuration

    class << self
      attr_writer :logger, :localizer

      def logger
        @logger ||= _default_logger
      end

      def localizer
        @localizer ||= Localizer.new
      end

      private

      def _default_logger
        logger = ::Logger.new("/dev/null")
        logger.level = ::Logger::INFO
        logger
      end
    end

  end
end
