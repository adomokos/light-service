module LightService
  module Testing
    class ContextFactory
      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        @organizer.before_action = [
          lambda do |ctx|
             if ctx.current_action == action
               ctx.skip_remaining!
             end
          end
        ]

        self
      end

      def with(ctx)
        @organizer.call(ctx)
      end

      def initialize(organizer)
        @organizer = organizer
      end
    end
  end
end
