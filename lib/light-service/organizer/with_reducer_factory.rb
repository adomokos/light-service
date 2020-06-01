module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        logger = monitored_organizer.logger ||
                 LightService::Configuration.logger
        decorated = WithReducer.new(monitored_organizer)

        return decorated if logger.nil?

        WithReducerLogDecorator.new(
          monitored_organizer,
          :decorated => decorated,
          :logger => logger
        )
      end
    end
  end
end
