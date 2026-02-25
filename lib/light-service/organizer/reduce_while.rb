module LightService
  module Organizer
    class ReduceWhile
      extend ScopedReducable

      def self.run(organizer, condition_block, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          Array(steps).each do |step|
            break unless condition_block.call(ctx)

            ctx = scoped_reduce(organizer, ctx, step)
            break if ctx.stop_processing?
          end

          ctx
        end
      end
    end
  end
end
