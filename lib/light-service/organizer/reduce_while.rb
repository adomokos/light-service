module LightService
  module Organizer
    class ReduceWhile
      def self.run(organizer, condition_block, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          reset_skip(ctx)

          Array(steps).each do |step|
            break unless condition_block.call(ctx)

            ctx = organizer.with(ctx).reduce([step])
            break if ctx.stop_processing?
          end

          reset_skip(ctx)

          ctx
        end
      end

      def self.reset_skip(ctx)
        ctx.reset_skip_remaining! unless ctx.failure? || ctx.skip_all_remaining?
      end
      private_class_method :reset_skip
    end
  end
end
