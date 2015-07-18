module LightService
  module Action

    def self.extended(base_class)
      base_class.extend Macros
    end

    def self.included(base_class)
      ActiveSupport::Deprecation.warn "including Lightervice::Action is deprecated. Please use `extend LightService::Action` instead"
      base_class.extend Macros
    end

    def inherited(subclass)
      subclass.instance_variable_set(:@_expected_keys, @_expected_keys)
      subclass.instance_variable_set(:@_promised_keys, @_promised_keys)
      super(subclass)
    end

    module Macros
      def expects(*args)
        @_expected_keys ||= []
        @_expected_keys.concat(args)
      end

      def promises(*args)
        @_promised_keys ||= []
        @_promised_keys.concat(args)
      end

      def expected_keys
        @_expected_keys ||= []
      end

      def promised_keys
        @_promised_keys ||= []
      end

      def executed
        define_singleton_method :execute do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.stop_processing?

          # Store the action within the context
          action_context.current_action = self

          Context::KeyVerifier.verify_keys(action_context, self) do
            action_context.define_accessor_methods_for_keys(all_keys)

            yield(action_context)
          end
        end
      end

      def rolled_back
        raise "`rolled_back` macro can not be invoked again" if self.respond_to?(:rollback)

        define_singleton_method :rollback do |context = {}|
          yield(context)

          context
        end

      end

      private

      def create_action_context(context)
        if context.is_a? LightService::Context
          return context
        end

        LightService::Context.make(context)
      end

      def all_keys
        expected_keys + promised_keys
      end
    end

  end
end
