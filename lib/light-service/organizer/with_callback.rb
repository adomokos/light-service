module LightService
  module Organizer
    class WithCallback
      extend ScopedReducable

      def self.run(organizer, action, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          # This will only allow 2 level deep nesting of callbacks
          previous_callback = ctx[:callback]

          ctx[:callback] = lambda do |context|
            ctx = scoped_reduce(organizer, context, steps)
            ctx
          end

          ctx = action.execute(ctx)
          ctx[:callback] = previous_callback

          ctx
        end
      end
    end
  end
end
