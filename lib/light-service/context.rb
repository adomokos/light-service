module LightService
  module Outcomes
    SUCCESS = 0
    FAILURE = 1
  end

  class Context
    attr_accessor :outcome, :message

    def initialize(outcome=::LightService::Outcomes::SUCCESS, message='', context={})
      @outcome, @message, @context = outcome, message, context
    end

    def self.make(context={})
      Context.new(::LightService::Outcomes::SUCCESS, '', Hash(context))
    end

    # backport for ruby-2.0.0 Kernel#Hash, based on specification
    def self.Hash(context)
      return {} if (context == nil) || (context == [])
      context.to_hash rescue fail(TypeError, "can't convert #{context.inspect} to Hash")
    end

    def add_to_context(values)
      @context.merge! values
    end

    def [](index)
      @context[index]
    end

    def []=(index, value)
      @context[index] = value
    end

    def fetch(index)
      @context.fetch(index)
    end

    # It's really there for testing and debugging
    def context_hash
      @context.dup
    end

    def to_hash
      @context.dup
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
