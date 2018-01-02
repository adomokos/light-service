module LightService
  module Organizer
    class ReduceIf
      extend ScopedReducable

      def self.run(organizer, condition_block, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          ctx = scoped_reduce(organizer, ctx, steps) \
                  if condition_block.call(ctx)
          ctx
        end
      end
    end
  end
end
