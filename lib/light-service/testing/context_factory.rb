module LightService
  module Testing
    class ContextFactory
      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        @organizer.before_actions = [
          lambda do |ctx|
            if ctx.current_action == action
              throw(:return_ctx_from_execution, ctx)
            end
          end
        ]

        self
      end

      def with(ctx)
        escaped = catch(:return_ctx_from_execution) do
          @organizer.call(ctx)
        end

        escaped
      end

      def initialize(organizer)
        @organizer = organizer
      end
    end
  end
end
