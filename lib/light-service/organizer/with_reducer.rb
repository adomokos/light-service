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

    def print_pipeline_for(*actions)
      ::Organizer::PipelinePrinter.new(context.dup).print(*actions)
    end
  end
end; end
