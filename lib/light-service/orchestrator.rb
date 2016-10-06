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
        steps.each_with_object(context) do |step, ctx|
          if step.respond_to?(:execute)
            step.execute(ctx)
          elsif step.respond_to?(:call)
            step.call(ctx)
          else
            raise 'Pass either an action or organizer'
          end
        end
      end

      def reduce_until(condition_block, steps)
        lambda do |ctx|
          loop do
            ctx = scoped_reduction(ctx, steps)
            break if condition_block.call(ctx) || ctx.failure?
          end

          ctx
        end
      end

      def reduce_if(condition_block, steps)
        lambda do |ctx|
          ctx = scoped_reduction(ctx, steps) if condition_block.call(ctx)
          ctx
        end
      end

      def execute(code_block)
        lambda do |ctx|
          ctx = code_block.call(ctx)
          ctx
        end
      end

      def iterate(collection_key, steps)
        lambda do |ctx|
          collection = ctx[collection_key]
          item_key = collection_key.to_s.singularize.to_sym
          collection.each do |item|
            ctx[item_key] = item
            ctx = scoped_reduction(ctx, steps)
          end

          ctx
        end
      end

      private

      def scoped_reduction(ctx, steps)
        ctx.reset_skip_all! unless ctx.failure?
        ctx =
          if steps.is_a?(Array)
            reduce(steps, ctx)
          else
            reduce([steps], ctx)
          end
        ctx.reset_skip_all! unless ctx.failure?

        ctx
      end
    end
  end
end
