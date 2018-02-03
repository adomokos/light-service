module LightService
  module Organizer
    class ReduceUntil
      extend ScopedReducable

      def self.run(organizer, condition_block, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          loop do
            ctx = scoped_reduce(organizer, ctx, steps)
            break if condition_block.call(ctx) || ctx.failure?
          end

          ctx
        end
      end
    end
  end
end
