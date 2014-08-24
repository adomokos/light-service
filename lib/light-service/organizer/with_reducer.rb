module LightService
  class NoExpectsOrPromisesFoundOnActionError < StandardError; end

  module Organizer
    class WithReducer
      attr_reader :context

      def with(data = {})
        @context = LightService::Context.make(data)
        self
      end

      def reduce(*actions)
        raise "No action(s) were provided" if actions.empty?
        actions.flatten!

        actions.reduce(context) do |context, action|
          result = action.execute(context)
          yield(context, action) if block_given?
          result
        end
      end

      def reduce!(*actions)
        LightService::Context::KeyVerifier.verify_actions_has_expects_or_promises(actions)

        self.reduce(*actions)
      end
    end
  end
end
