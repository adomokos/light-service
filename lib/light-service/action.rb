module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      def executed
        define_singleton_method "execute" do |context|
          action_context = create_action_context(context)
          return action_context if action_context.failure? || action_context.skip_all?

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
    end

  end
end
