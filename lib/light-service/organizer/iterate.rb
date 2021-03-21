module LightService
  module Organizer
    class Iterate
      extend ScopedReducable

      # rubocop:disable Metrics/MethodLength
      def self.run(organizer, collection_key, steps)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          collection = ctx[collection_key]
          item_key = collection_key.to_s.singularize.to_sym
          collection.each do |item|
            ctx[item_key] = item

            ctx = scoped_reduce(organizer, ctx, steps)

            next unless ctx.key?(:_rollback)

            # Handle Rollback
            rollback_items(
              item,
              organizer,
              ctx,
              collection,
              steps
            )
          end

          ctx
        end
      end
      # rubocop:enable Metrics/MethodLength

      def self.rollback_items(item, organizer, ctx, collection, steps)
        reversed_processed_collection = \
          collection.take_while { |i| i != item }.reverse

        reversed_processed_collection.each do
          ctx = scoped_reduce_rollback(
            organizer,
            ctx,
            steps
          )
        end
      end
    end
  end
end
