module LightService; module Organizer
  class WithReducerLogDecorator
    attr_reader :logger, :decorated, :organizer
    def initialize(decorated = WithReducer.new, organizer)
      @decorated, @organizer = decorated, organizer
      @logger = ::LightService::Configuration.logger
    end

    def with(data = {})
      logger.info("[LightService] - calling organizer <#{organizer.to_s}>")

      decorated.with(data)

      logger.info("[LightService] -     keys in context: #{extract_keys(decorated.context.keys)}")
      self
    end

    def reduce(*actions)
      decorated.reduce(*actions) do |context, action|
        logger.info("[LightService] - executing <#{action.to_s}>")
        if defined? action.expects and action.expects.any?
          logger.info("[LightService] -   expects: #{extract_keys(action.expects)}")
        end
        if defined? action.promises and action.promises.any?
          logger.info("[LightService] -   promises: #{extract_keys(action.promises)}") 
        end
        logger.info("[LightService] -     keys in context: #{extract_keys(context.keys)}")
      end
    end

    private
    def extract_keys(keys)
      keys.map {|key| ":#{key}" }.join(', ')
    end
  end
end; end
