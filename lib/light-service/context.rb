module LightService
  module Outcomes
    SUCCESS = 0
    FAILURE = 1
  end

  class Context < Hash
    attr_accessor :outcome, :message

    def initialize(context={}, outcome=::LightService::Outcomes::SUCCESS, message='')
      @outcome, @message = outcome, message
      context.to_hash.each {|k,v| self[k] = v}
      self
    end

    def self.make(context={})
      self.new(context, ::LightService::Outcomes::SUCCESS, '')
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
      @message = message
      @outcome = ::LightService::Outcomes::SUCCESS
    end

    def set_failure!(message)
      @message = message
      @outcome = ::LightService::Outcomes::FAILURE
    end

    def skip_all!(message = nil)
      @message = message
      @skip_all = true
    end
  end
end
