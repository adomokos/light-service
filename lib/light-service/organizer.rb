module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
    end
    def self.included(base_class)
      ActiveSupport::Deprecation.warn "including Lightervice::Organizer is deprecated. Please use `extend LightService::Organizer` instead"
      base_class.extend ClassMethods
    end

    # In case this module is included
    module ClassMethods
      def with(data)
        WithReducerFactory.make(self).with(data)
      end

      def reduce(*actions)
        WithReducerFactory.make(self).with.reduce(actions)
      end
    end

    # Provide hooks for extending the class with these methods
    def with(data = {})
      WithReducerFactory.make(self).with(data)
    end

    def reduce(*actions)
      WithReducerFactory.make(self).with.reduce(actions)
    end

  end
end
