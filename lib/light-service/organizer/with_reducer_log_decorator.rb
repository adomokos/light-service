module LightService; module Organizer
  class WithReducerLogDecorator
    def initialize(decorated = WithReducer.new, organizer)
      @decorated, @organizer = decorated, organizer
      @logger = ::LightService::Configuration.logger
    end

    def with(data = {})
      @logger.info("[LightService] - calling organizer #{@organizer.to_s}")

      result = @decorated.with(data)

      @logger.info("[LightService] - keys in context: #{keys_in_context(@decorated.context)}")

      result
    end

    def reduce(*actions)
      @decorated.reduce(actions)
    end

    def print_pipeline_for(*actions)
      @decorated.print_pipeline_for(actions)
    end

    private
    def keys_in_context(context)
      context.keys.map {|key| ":#{key}" }.join(', ')
    end
  end
end; end
