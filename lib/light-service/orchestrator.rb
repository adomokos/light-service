module LightService
  module Orchestrator
    def self.extended(base_class)
      base_class.extend ClassMethods
    end

    module ClassMethods
      def with(data = {})
        @context = LightService::Context.make(data)
        self
      end

      def reduce(steps, context = @context)
        issue_deprecation_warning_for(__method__)

        steps.each_with_object(context) do |step, ctx|
          if step.respond_to?(:call)
            step.call(ctx)
          elsif step.respond_to?(:execute)
            step.execute(ctx)
          else
            raise 'Pass either an action or organizer'
          end
        end
      end

      def reduce_until(condition_block, steps)
        issue_deprecation_warning_for(__method__)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          loop do
            ctx = scoped_reduction(ctx, steps)
            break if condition_block.call(ctx) || ctx.failure?
          end

          ctx
        end
      end

      def reduce_if(condition_block, steps)
        issue_deprecation_warning_for(__method__)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          ctx = scoped_reduction(ctx, steps) if condition_block.call(ctx)
          ctx
        end
      end

      def execute(code_block)
        issue_deprecation_warning_for(__method__)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          ctx = code_block.call(ctx)
          ctx
        end
      end

      def iterate(collection_key, steps)
        issue_deprecation_warning_for(__method__)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          collection = ctx[collection_key]
          item_key = collection_key.to_s.singularize.to_sym
          collection.each do |item|
            ctx[item_key] = item
            ctx = scoped_reduction(ctx, steps)
          end

          ctx
        end
      end

      def with_callback(action, steps)
        issue_deprecation_warning_for(__method__)

        lambda do |ctx|
          return ctx if ctx.stop_processing?

          # This will only allow 2 level deep nesting of callbacks
          previous_callback = ctx[:callback]

          ctx[:callback] = lambda do |context|
            reduce(steps, context)
          end

          ctx = action.execute(ctx)
          ctx[:callback] = previous_callback

          ctx
        end
      end

      private

      def scoped_reduction(ctx, steps)
        ctx.reset_skip_remaining! unless ctx.failure?
        ctx =
          if steps.is_a?(Array)
            reduce(steps, ctx)
          else
            reduce([steps], ctx)
          end
        ctx.reset_skip_remaining! unless ctx.failure?

        ctx
      end

      def issue_deprecation_warning_for(method_name)
        msg = "`Orchestrator##{method_name}` is DEPRECATED and will be " \
              "removed, please switch to `Organizer##{method_name} instead. "
        warn(StructuredWarnings::DeprecatedMethodWarning, msg)
      end
    end
  end
end
