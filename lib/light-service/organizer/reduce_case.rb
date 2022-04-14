module LightService
  module Organizer
    class ReduceCase
      extend ScopedReducable

      class Arguments
        attr_reader :value, :when, :else

        def initialize(**args)
          validate_arguments(**args)
          @value = args[:value]
          @when = args[:when]
          @else = args[:else]
        end

        private

        # rubocop:disable Style/MultilineIfModifier
        def validate_arguments(**args)
          raise(
            ArgumentError,
            "Expected keyword arguments: [:value, :when, :else]. Given: #{args.keys}"
          ) unless args.keys.intersection(mandatory_arguments).count == mandatory_arguments.count
        end
        # rubocop:enable Style/MultilineIfModifier

        def mandatory_arguments
          %i[value when else]
        end
      end

      def self.run(organizer, **args)
        arguments = Arguments.new(**args)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          matched_case = arguments.when.keys.find { |k| k.eql?(ctx[arguments.value]) }
          steps = arguments.when[matched_case] || arguments.else

          ctx = scoped_reduce(organizer, ctx, steps)

          ctx
        end
      end
    end
  end
end