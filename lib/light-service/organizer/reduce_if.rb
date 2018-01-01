module LightService
  module Organizer
    class ReduceIf
      def self.run(organizer, condition_block, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          ctx = scoped_reduction(organizer, ctx, steps) \
                  if condition_block.call(ctx)
          ctx
        end
      end

      def self.scoped_reduction(organizer, ctx, steps)
        ctx.reset_skip_remaining! unless ctx.failure?
        ctx = organizer.with(ctx).reduce([steps])
        ctx.reset_skip_remaining! unless ctx.failure?

        ctx
      end
    end
  end
end
