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
            if (ctx.key?(:_rollback))
              reversed_processed_collection = collection.take_while { |i| i != item }.reverse
              rollback_items(organizer, ctx, reversed_processed_collection, steps)
              break
            end
          end

          ctx
        end
      end

      def self.rollback_items(organizer, ctx, collection, steps)
        collection.each do |item|
          ctx = scoped_reduce_rollback(organizer, ctx, steps)
        end
      end
    end
  end
end
