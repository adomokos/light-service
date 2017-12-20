module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        if LightService::Configuration.logger.nil?
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
