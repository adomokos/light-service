module LightService
  module Refinements
    module Array
      refine ::Array do
        def self.wrap(object)
          if object.nil?
            []
          elsif object.respond_to?(:to_ary)
            object.to_ary || [object]
          else
            [object]
          end
        end
      end
    end
  end
end
