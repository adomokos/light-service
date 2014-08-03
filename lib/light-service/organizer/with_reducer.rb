module LightService; module Organizer
  class WithReducer
    attr_reader :context

    def with(data = {})
      @context = LightService::Context.make(data)
      self
    end

    def reduce(*actions)
      raise "No action(s) were provided" if actions.empty?
      actions.flatten!
      actions.reduce(context) { |context, action| action.execute(context) }
    end
  end
end; end
