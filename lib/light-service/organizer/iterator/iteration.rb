module LightService
  module Organizer
    Iteration = Struct.new(:item, :item_key, :actions) do
      def include?(action)
        actions.include?(action)
      end
    end
  end
end
