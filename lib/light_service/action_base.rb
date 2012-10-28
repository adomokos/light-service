module LightService
  class ActionBase

    def self.action_execute
      define_singleton_method "execute" do |context|
        return context if context.failure?

        yield(context)

        context
      end
    end

  end
end
