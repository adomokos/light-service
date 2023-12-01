module LightService
  module Organizer
    def self.extended(base_class)
      base_class.extend ClassMethods
      base_class.extend Macros
    end

    def self.included(base_class)
      warning_msg = "including LightService::Organizer is deprecated. " \
                    "Please use `extend LightService::Organizer` instead"
      LightService::Deprecation.warn(warning_msg)
      extended(base_class)
    end

    # In case this module is included
    module ClassMethods
      def with(data = {})
        VerifyCallMethodExists.run(self, caller(1..1).first)
        data[:_aliases] = @aliases if @aliases

        if @before_actions
          data[:_before_actions] = @before_actions.dup
          @before_actions = nil
        end

        if @after_actions
          data[:_after_actions] = @after_actions.dup
          @after_actions = nil
        end

        WithReducerFactory.make(self).with(data)
      end

      def reduce(*actions)
        with({}).reduce(actions)
      end

      def reduce_if(condition_block, steps)
        ReduceIf.run(self, condition_block, steps)
      end

      def reduce_if_else(condition_block, if_steps, else_steps)
        ReduceIfElse.run(self, condition_block, if_steps, else_steps)
      end

      def reduce_until(condition_block, steps)
        ReduceUntil.run(self, condition_block, steps)
      end

      def reduce_case(**args)
        ReduceCase.run(self, **args)
      end

      def iterate(collection_key, steps)
        Iterate.run(self, collection_key, steps)
      end

      def execute(code_block)
        Execute.run(code_block)
      end

      def with_callback(action, steps)
        WithCallback.run(self, action, steps)
      end

      def log_with(logger)
        @logger = logger
      end

      def logger
        @logger
      end

      # Set the value as a key on the context hash
      # and also create convenience accessors for the keys
      def add_to_context(args)
        Context::ReservedKeysViaOrganizerVerifier.new(args).verify

        Hash(args).map do |key, value|
          context_key = lambda do |ctx|
            ctx[key.to_sym] = value
            ctx.define_accessor_methods_for_keys(key)
          end

          execute(context_key)
        end
      end

      def add_aliases(args)
        execute(->(ctx) { ctx.assign_aliases(ctx.aliases.merge(args)) })
      end
    end

    module Macros
      def aliases(key_hash)
        @aliases = key_hash
      end

      # This looks like an accessor,
      # but it's used as a macro in the Organizer
      def before_actions(*logic)
        self.before_actions = logic
      end

      def before_actions=(logic)
        @before_actions = [logic].flatten
      end

      def append_before_actions(action)
        @before_actions ||= []
        @before_actions.push(action)
      end

      # This looks like an accessor,
      # but it's used as a macro in the Organizer
      def after_actions(*logic)
        self.after_actions = logic
      end

      def after_actions=(logic)
        @after_actions = [logic].flatten
      end

      def append_after_actions(action)
        @after_actions ||= []
        @after_actions.push(action)
      end
    end
  end
end
