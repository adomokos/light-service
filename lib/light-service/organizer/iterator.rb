module LightService
  module Organizer
    class Iterator
      using ::LightService::Refinements::Array

      def initialize(collection_key, actions)
        @collection_key = collection_key
        @actions = actions
        @iterations = nil
        @current_iteration = nil
      end

      def rollback(ctx)
        reversed_rollbackable_iterations
          .each_with_index do |current_iteration, idx|
            ctx[current_iteration.item_key] = current_iteration.item

            # If we're rollbacking the first reversable iteration (idx == 0)
            # than we want to start rollback from the current action: eventual
            # later actions were not run yet so we won't roll them back.
            # OR
            # if current action is not inside current iteration, then the
            # rollback is coming from the outside, in an action executed
            # later. So we need to reset current action to the bottomest
            # action in the iteration
            if idx.positive? || !current_iteration.include?(ctx.current_action)
              # Otherwise we necesarily want to start from the last action.
              ctx.current_action = current_iteration.actions.last
            end

            ctx = LightService::Organizer::WithReducer
                  .new(self)
                  .with(ctx)
                  .reduce_rollback(current_iteration.actions)
          end

        ctx
      end

      def call(ctx)
        return ctx if ctx.stop_processing?

        outer_organizer = ctx.organized_by

        setup_iterations(ctx, @collection_key, @actions)

        @iterations.each do |single_iteration|
          ctx[@iterations.item_key] = single_iteration.item
          @current_iteration = single_iteration
          ctx = LightService::Organizer::WithReducer
                .new(self)
                .with(ctx)
                .reduce(single_iteration.actions)
        end

        ctx.organized_by = outer_organizer
        ctx.current_action = self
        ctx
      end

      def self.run(_organizer, collection_key, actions)
        new(collection_key, Array.wrap(actions))
      end

      private

      def setup_iterations(ctx, collection_key, actions)
        # rubocop:disable Naming/MemoizedInstanceVariableName
        @iterations ||= Iterations.new(ctx, collection_key, actions)
        # rubocop:enable Naming/MemoizedInstanceVariableName
      end

      def rollbackable_iterations
        index_of_current_iteration =
          @iterations.index(@current_iteration) || 0

        # Reverse from the point where the fail was triggered
        @iterations.take(index_of_current_iteration + 1)
      end

      def reversed_rollbackable_iterations
        rollbackable_iterations.reverse
      end
    end
  end
end
