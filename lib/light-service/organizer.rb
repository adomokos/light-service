module LightService
  module Organizer
    def self.included(base_class)
      base_class.extend ClassMethods
    end

    module ClassMethods
      def with(data)
        new.with(data)
      end
    end

    def with(data = {})
      @context = LightService::Context.make(data)
      self
    end

    def reduce(actions=[])
      actions.reduce(@context) { |context, action| action.execute(context) }
    end
  end
end
