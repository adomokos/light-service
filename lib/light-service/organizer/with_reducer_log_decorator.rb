module LightService; module Organizer
  class WithReducerLogDecorator
    attr_reader :logger, :decorated, :organizer

    def initialize(decorated = WithReducer.new, organizer)
      @decorated, @organizer = decorated, organizer
      @logger = ::LightService::Configuration.logger
      @logged = false
    end

    def with(data = {})
      logger.info("[LightService] - calling organizer <#{organizer.to_s}>")

      decorated.with(data)

      logger.info("[LightService] -     keys in context: #{extract_keys(decorated.context.keys)}")
      self
    end

    def reduce(*actions)
      decorated.reduce(*actions) do |context, action|
        next if no_more_logs?
        next if has_failure?(context, action)
        next if skip_all?(context, action)

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
    def logged?
      @logged
    end

    def extract_keys(keys)
      keys.map {|key| ":#{key}" }.join(', ')
    end

    def has_failure?(context, action)
      return false unless context.respond_to?(:failure?) && context.failure?

      logger.warn("[LightService] - :-((( <#{action.to_s}> has failed...")
      logger.warn("[LightService] - context message: #{context.message}")
      @logged = true
    end

    def skip_all?(context, action)
      return false unless context.respond_to?(:skip_all?) && context.skip_all?

      logger.info("[LightService] - ;-) <#{action.to_s}> has decided to skip the rest of the actions")
      logger.info("[LightService] - context message: #{context.message}")
      @logged = true
    end

    def no_more_logs?
      @logged
    end
  end
end; end
