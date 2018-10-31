module LightService
  module Organizer
    class WithReducer
      attr_reader :context

      def with(data = {})
        @context = LightService::Context.make(data)
        self
      end

      def around_each(handler)
        @around_each_handler = handler
        self
      end

      def around_each_handler
        @around_each_handler ||= Class.new do
          def self.call(_context)
            yield
          end
        end
      end

      def reduce(*actions)
        raise "No action(s) were provided" if actions.empty?

        actions.flatten!

        actions.each_with_object(context) do |action, current_context|
          begin
            invoke_action(current_context, action)
          rescue FailWithRollbackError
            reduce_rollback(actions)
          ensure
            # For logging
            yield(current_context, action) if block_given?
          end
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
        around_each_handler.call(current_context) do
          if action.respond_to?(:call)
            action.call(current_context)
          else
            action.execute(current_context)
          end
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
