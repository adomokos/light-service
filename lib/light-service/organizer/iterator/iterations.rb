require 'forwardable'

module LightService
  module Organizer
    class Iterations
      extend Forwardable

      attr_reader :collection,
                  :item_key

      def initialize(ctx, collection_key, actions)
        collection = ctx[collection_key]
        @item_key = collection_key.to_s.singularize.to_sym

        @collection = collection.each_with_object([]) do |item, memo|
          memo << Iteration.new(item, item_key, actions)
        end
      end

      def_delegator :collection, :index
      def_delegator :collection, :take
      def_delegator :collection, :each
    end
  end
end
