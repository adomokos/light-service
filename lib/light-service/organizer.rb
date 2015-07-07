module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
      base_class.extend Macros
    end
    def self.included(base_class)
      ActiveSupport::Deprecation.warn "including Lightervice::Organizer is deprecated. Please use `extend LightService::Organizer` instead"
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    # In case this module is included
    module ClassMethods
      def with(data)
        WithReducerFactory.make(self).with(data.merge(:_aliases => @aliases))
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end
    end

    module Macros
      def aliases(key_hash)
        @aliases = key_hash
      end
    end
  end
end
