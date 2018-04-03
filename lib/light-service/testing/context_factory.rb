module LightService
  module Testing
    class ContextFactory
      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        @organizer.append_before_actions(
          lambda do |ctx|
            if ctx.current_action == action
              # The last `:_before_actions` hook is for
              # ContextFactory, remove it, so it won't
              # be invoked again
              ctx[:_before_actions].pop

              throw(:return_ctx_from_execution, ctx)
            end
          end
        )

        self
      end

      # More than one arguments can be passed to the
      # Organizer's #call method
      def with(*args, &block)
        catch(:return_ctx_from_execution) do
          @organizer.call(*args, &block)
        end
      end

      def initialize(organizer)
        @organizer = organizer
      end
    end
  end
end
