module LightService
  class Configuration

    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= self._default_logger
    end

    def self._default_logger
      #logger = Logger.new("/dev/null")
      logger = Logger.new(STDOUT)
      logger.level = ::Logger::INFO
      logger
    end

  end
end
