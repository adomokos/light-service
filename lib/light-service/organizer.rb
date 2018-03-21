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
        VerifyCallMethodExists.run(self, caller(1..1).first)
        data[:_aliases] = @aliases if @aliases

        if @before_action_logic
          data[:_before_action] = @before_action_logic
          @before_action_logic = nil
        end

        WithReducerFactory.make(self).with(data)
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end

      def reduce_if(condition_block, steps)
        ReduceIf.run(self, condition_block, steps)
      end

      def reduce_until(condition_block, steps)
        ReduceUntil.run(self, condition_block, steps)
      end

      def iterate(collection_key, steps)
        Iterate.run(self, collection_key, steps)
      end

      def execute(code_block)
        Execute.run(code_block)
      end

      def with_callback(action, steps)
        WithCallback.run(self, action, steps)
      end
    end

    module Macros
      def aliases(key_hash)
        @aliases = key_hash
      end

      def before_action=(logic)
        @before_action_logic = logic
      end
    end
  end
end
