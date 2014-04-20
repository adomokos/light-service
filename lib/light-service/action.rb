module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      def expects(*args)
        @expects_keys = args
      end

      def expects_keys
        @expects_keys ||= []
      end

      def promises(*args)
        @promises_keys = args
      end

      def promises_keys
        @promises_keys ||= []
      end

      def executed
        define_singleton_method "execute" do |context = {}|
          action_context = create_action_context(context)
          return action_context if action_context.failure? || action_context.skip_all?

          define_expectation_accessors action_context

          yield(action_context)

          action_context
        end
      end

      private

      def create_action_context(context)
        if context.respond_to? :failure?
          return context
        end

        LightService::Context.make(context)
      end

      def define_expectation_accessors(context)
        expects_keys.each do |x|
          if context.has_key?(x)
            define_singleton_method x do
              context.fetch(x)
            end
          else
            fail ArgumentError, "expected :#{x} to be in the context"
          end
        end
      end

    end

  end
end
