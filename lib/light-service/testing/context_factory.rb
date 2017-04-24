module LightService
  module Testing
    class ContextFactory
      class ContextFactoryOrganizer
        extend LightService::Organizer
        class << self
          attr_accessor :actions
        end

        def self.call(ctx)
          with(ctx).reduce(actions)
        end
      end

      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        ContextFactoryOrganizer.actions = find_up_to(action)
        self
      end

      def with(ctx)
        ContextFactoryOrganizer.call(ctx)
      end

      def initialize(organizer)
        @organizer = organizer
      end

      def find_up_to(action)
        original_actions = organizer.actions

        original_actions.take_while do |current_action|
          current_action != action
        end
      end
    end
  end
end
