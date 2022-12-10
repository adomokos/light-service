require 'forwardable'

module LightService
  class Deprecation
    def self.warn(message)
      logger.warn(message)
    end

    def self.logger
      @logger ||= Logger.new
    end
    private_class_method :logger

    class Logger
      extend Forwardable

      attr_reader :logger

      def initialize
        @logger = ::Logger.new($stderr)
        @logger.level = ::Logger::WARN
        @logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "[DEPRECATION] #{caller[5]}: #{msg}\n"
        end
      end

      def_delegator :@logger, :warn
    end
  end
end
