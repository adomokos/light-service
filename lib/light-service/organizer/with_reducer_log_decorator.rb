module LightService; module Organizer
  class WithReducerLogDecorator
    attr_reader :logged, :logger, :decorated, :organizer

    alias_method :logged?, :logged

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
        next if logged?
        if has_failure?(context)
          write_failure_log(context, action) and next
        end
        if skip_all?(context)
          write_skip_all_log(context, action) and next
        end

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

    def reduce!(*actions)
      decorated.reduce!(*actions)
    end

    private

    def extract_keys(keys)
      keys.map {|key| ":#{key}" }.join(', ')
    end

    def has_failure?(context)
      context.respond_to?(:failure?) && context.failure?
    end

    def write_failure_log(context, action)
      logger.warn("[LightService] - :-((( <#{action.to_s}> has failed...")
      logger.warn("[LightService] - context message: #{context.message}")
      @logged = true
    end

    def skip_all?(context)
      context.respond_to?(:skip_all?) && context.skip_all?
    end

    def write_skip_all_log(context, action)
      logger.info("[LightService] - ;-) <#{action.to_s}> has decided to skip the rest of the actions")
      logger.info("[LightService] - context message: #{context.message}")
      @logged = true
    end
  end
end; end
