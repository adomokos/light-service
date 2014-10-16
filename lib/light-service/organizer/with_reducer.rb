module LightService; module Organizer
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
        begin
          result = action.execute(context)
        rescue FailWithRollbackError
          result = reduce_rollback(actions)
        ensure
          # For logging
          yield(context, action) if block_given?
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

    def reversable_actions(actions)
      index_of_current_action = actions.index(@context.current_action) || 0

      # Reverse from the point where the fail was triggered
      actions.take(index_of_current_action + 1)
    end
  end
end; end
