module LightService
  module Organizer
    class Iterate
      extend ScopedReducable

      def self.run(organizer, collection_key, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          collection = ctx[collection_key]
          item_key = collection_key.to_s.singularize.to_sym
          collection.each do |item|
            ctx[item_key] = item
            ctx = scoped_reduce(organizer, ctx, steps)
          end

          ctx
        end
      end
    end
  end
end
