module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      def executed
        define_singleton_method "execute" do |context|
          return context if context.failure?

          yield(context)

          context
        end
      end
    end

  end
end
