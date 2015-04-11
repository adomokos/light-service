module LightService
  module Outcomes
    SUCCESS = 0
    FAILURE = 1
  end

  class Context < Hash
    attr_accessor :message, :error_code, :current_action

    def initialize(context={}, outcome=Outcomes::SUCCESS, message='', error_code=nil)
      @outcome, @message, @error_code = outcome, message, error_code
      @skip_all = false
      context.to_hash.each {|k,v| self[k] = v}
      self
    end

    def self.make(context={})
      unless context.is_a? Hash or context.is_a? LightService::Context
        raise ArgumentError, 'Argument must be Hash or LightService::Context'
      end

      return context if context.is_a?(Context)
      self.new(context)
    end

    def add_to_context(values)
      self.merge! values
    end

    def success?
      @outcome == Outcomes::SUCCESS
    end

    def failure?
      success? == false
    end

    def skip_all?
      @skip_all
    end

    def outcome
      ActiveSupport::Deprecation.warn '`Context#outcome` attribute reader is DEPRECATED and will be removed'
      @outcome
    end

    def succeed!(message=nil, options={})
      @message = Configuration.localization_adapter.success(message, current_action, options)
      @outcome = Outcomes::SUCCESS
    end

    def fail!(message=nil, options_or_error_code={})
      options_or_error_code ||= {}

      if options_or_error_code.is_a?(Hash)
        error_code = options_or_error_code.delete(:error_code)
        options = options_or_error_code
      else
        error_code = options_or_error_code
        options = {}
      end

      @message = Configuration.localization_adapter.failure(message, current_action, options)
      @error_code = error_code
      @outcome = Outcomes::FAILURE
    end

    def fail_with_rollback!(message=nil, error_code=nil)
      fail!(message, error_code)
      raise FailWithRollbackError.new
    end

    def skip_all!(message=nil)
      @message = message
      @skip_all = true
    end

    def stop_processing?
      failure? || skip_all?
    end

    def define_accessor_methods_for_keys(keys)
      return if keys.nil?
      keys.each do |key|
        next if self.respond_to?(key.to_sym)
        define_singleton_method("#{key}") { self.fetch(key) }
        define_singleton_method("#{key}=") { |value| self[key] = value }
      end
    end
  end
end
