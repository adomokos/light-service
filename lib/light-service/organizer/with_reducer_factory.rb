module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        logger = monitored_organizer.logger ||
                 LightService::Configuration.logger
        decorated = WithReducer.new

        if logger.nil?
          # :nocov:
          WithReducer.new
          # :nocov:
        else
          WithReducerLogDecorator.new(monitored_organizer, WithReducer.new)
        end
      end
    end
  end
end
