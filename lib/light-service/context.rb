module LightService
  module Outcomes
    SUCCESS = 0
    FAILURE = 1
  end

  class Context < Hash
    attr_accessor :outcome, :message, :error_code

    def initialize(context={}, outcome=::LightService::Outcomes::SUCCESS, message='', error_code=nil)
      @outcome, @message, @error_code = outcome, message, error_code
      context.to_hash.each {|k,v| self[k] = v}
      self
    end

    def self.make(context={})
      unless context.is_a? Hash or context.is_a? ::LightService::Context
        raise ArgumentError, 'Argument must be Hash or LightService::Context'
      end

      return context if context.is_a?(Context)
      self.new(context)
    end

    def add_to_context(values)
      self.merge! values
    end

    # It's really there for testing and debugging
    # Deprecated: Please use `to_hash` instead
    def context_hash
      warn 'DEPRECATED: Please use `to_hash` instead'
      self.dup
    end

    def success?
      @outcome == ::LightService::Outcomes::SUCCESS
    end

    def failure?
      success? == false
    end

    def skip_all?
      @skip_all
    end

    def set_success!(message)
      warn '`set_success!` is DEPRECATED: please use `succeed!` instead'
      succeed!(message)
    end

    def succeed!(message=nil)
      @message = message
      @outcome = ::LightService::Outcomes::SUCCESS
    end

    def set_failure!(message)
      warn '`set_failure!` is DEPRECATED: please use `fail!` instead'
      fail!(message)
    end

    def fail!(options=nil)
      if options.is_a? Hash
        @message = options[:message]
        @error_code = options[:error_code]
      else
        @message = options
      end
      @outcome = ::LightService::Outcomes::FAILURE
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
        define_singleton_method("#{key}") { self.fetch(key) }
        define_singleton_method("#{key}=") { |value| self[key] = value }
      end
    end
  end
end
