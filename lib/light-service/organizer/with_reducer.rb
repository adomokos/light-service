module LightService
  module Organizer
    class WithReducer
      attr_reader :context, :around_each_handler

      def with(data = {})
        @context = LightService::Context.make(data)
        self
      end

      def around_each(handler)
        @around_each_handler = handler
        self
      end

      def reduce(*actions)
        fail "No action(s) were provided" if actions.empty?
        actions.flatten!

        actions.reduce(context) do |current_context, action|
          begin
            result = invoke_action(current_context, action)
          rescue FailWithRollbackError
            result = reduce_rollback(actions)
          ensure
            # For logging
            yield(current_context, action) if block_given?
          end

          result
        end
      end

      def reduce_rollback(actions)
        reversable_actions(actions)
          .reverse
          .reduce(context) do |context, action|
            if action.respond_to?(:rollback)
              action.rollback(context)
            else
              context
            end
          end
      end

      private

      def invoke_action(current_context, action)
        return action.execute(current_context) unless around_each_handler

        around_each_handler.call(action, current_context) do
          action.execute(current_context)
        end
      end

      def reversable_actions(actions)
        index_of_current_action = actions.index(@context.current_action) || 0

        # Reverse from the point where the fail was triggered
        actions.take(index_of_current_action + 1)
      end
    end
  end
end
