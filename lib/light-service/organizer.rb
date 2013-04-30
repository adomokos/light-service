module LightService
  module Organizer
    protected
      def with(data = {})
        @context = data.kind_of?(::LightService::Context) ?
                     data :
                     LightService::Context.make(data)
        self
      end

      def reduce(actions=[])
        actions.reduce(@context) { |context, action| action.execute(context) }
      end
  end
end
