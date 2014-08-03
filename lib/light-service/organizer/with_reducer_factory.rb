module LightService
  module Organizer
    class WithReducerFactory
      def self.make(monitored_organizer)
        if (LightService::Configuration.logger.nil?)
          ::LightService::Organizer::WithReducer.new
        else
          ::LightService::Organizer::WithReducerLogDecorator.new(
            ::LightService::Organizer::WithReducer.new, monitored_organizer)
        end
      end
    end
  end
end
