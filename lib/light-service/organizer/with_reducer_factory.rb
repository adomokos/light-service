module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        if LightService::Configuration.logger.nil?
          WithReducer.new
        else
          WithReducerLogDecorator.new(monitored_organizer, WithReducer.new)
        end
      end
    end
  end
end
