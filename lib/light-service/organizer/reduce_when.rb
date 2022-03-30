module LightService
  module Organizer
    class ReduceWhen
      extend ScopedReducable
      
      def self.run(organizer, value_key, cases, else_steps)
      lambda do |ctx|
        return ctx if ctx.stop_processing?

        steps = cases[ctx[value_key].to_sym] || else_steps

        ctx = scoped_reduce(organizer, ctx, steps)

        ctx
      end
    end
    end
  end
end
