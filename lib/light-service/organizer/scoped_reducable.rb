module LightService
  module Organizer
    module ScopedReducable
      def scoped_reduce(organizer, ctx, steps)
        ctx.reset_skip_remaining! unless ctx.failure? || ctx.skip_all_remaining?
        ctx = organizer.with(ctx).reduce([steps])
        ctx.reset_skip_remaining! unless ctx.failure? || ctx.skip_all_remaining?

        ctx
      end
    end
  end
end
