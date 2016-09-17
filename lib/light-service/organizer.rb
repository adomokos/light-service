require 'active_support/deprecation'

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
      extended(base_class)
    end

    # In case this module is included
    module ClassMethods
      def with(data = {})
        VerifyCallMethodExists.call(self)
        data[:_aliases] = @aliases if @aliases
        WithReducerFactory.make(self).with(data)
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end

      # We need to make sure existing users will
      # use `call` method name going forward.
      # This should be removed eventually.
      class VerifyCallMethodExists
        def self.call(klass)
          call_method_exists = klass.methods.include?(:call)
          return if call_method_exists

          warning_msg = "The <#{klass.name}> class is an organizer, " \
                        "its entry method (the one that calls with & reduce) " \
                        "should be named `call`. " \
                        "Please use #{klass}.call going forward."
          ActiveSupport::Deprecation.warn(warning_msg)
        end
      end
    end

    module Macros
      def aliases(key_hash)
        @aliases = key_hash
      end
    end
  end
end
