module LightService
  module Organizer
    def self.included(base_class)
      base_class.extend ClassMethods
    end

    module ClassMethods
      def with(data)
        WithReducerFactory.make(self).with(data)
      end

      def reduce(actions)
        WithReducerFactory.make(self).with.reduce(actions)
      end
    end

  end
end
