module LightService
  module Organizer
    module ScopedReducable
      def scoped_reduce(organizer, ctx, steps)
        ctx.reset_skip_remaining! unless ctx.failure?
        ctx = organizer.with(ctx).reduce([steps])
        ctx.reset_skip_remaining! unless ctx.failure?

        ctx
      end

      def scoped_reduce_rollback(organizer, ctx, steps)
        ctx.reset_skip_remaining! unless ctx.failure?
        ctx = organizer.with(ctx).reduce_rollback(steps)
        ctx.reset_skip_remaining! unless ctx.failure?

        ctx
      end
    end
  end
end
