require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestExecuteWithAddToContext
    extend LightService::Organizer

    def self.call
      with().reduce(steps)
    end

    def self.steps
      [
        add_to_context(:greeting => "hello"),
        execute(->(ctx) { ctx.greeting.upcase! })
      ]
    end
  end

  context "when using context values created by add_to_context" do
    it "is expected to reference them as accessors" do
      result = TestExecuteWithAddToContext.call()

      expect(result).to be_a_success
      expect(result.greeting).to eq "HELLO"
    end
  end
end
