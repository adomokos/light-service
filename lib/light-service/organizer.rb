module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    def self.included(base_class)
      warning_msg = "including LightService::Organizer is deprecated. " \
                    "Please use `extend LightService::Organizer` instead"
      ActiveSupport::Deprecation.warn(warning_msg)
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    # In case this module is included
    module ClassMethods
      def with(data = {})
        data[:_aliases] = @aliases if @aliases
        WithReducerFactory.make(self).with(data)
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
