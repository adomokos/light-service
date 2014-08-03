module LightService; module Organizer
  class WithReducerLogDecorator
    def initialize(decorated = WithReducer.new, organizer)
      @decorated, @organizer = decorated, organizer
      @logger = ::LightService::Configuration.logger
    end

    def with(data = {})
      @logger.info("[LightService] - calling organizer #{@organizer.to_s}")

      @decorated.with(data)

      @logger.info("[LightService] -     keys in context: #{extract_keys(@decorated.context.keys)}")
      self
    end

    def reduce(*actions)
      @decorated.reduce(*actions) do |context, action|
        @logger.info("[LightService] - executing #{action.to_s}")
        @logger.info("[LightService] -   expects: #{extract_keys(action.expects)}") if defined? action.expects
        @logger.info("[LightService] -   promises: #{extract_keys(action.promises)}") if defined? action.promises
        @logger.info("[LightService] -     keys in context: #{extract_keys(context.keys)}")
      end
    end

    private
    def extract_keys(keys)
      keys.map {|key| ":#{key}" }.join(', ')
    end
  end
end; end