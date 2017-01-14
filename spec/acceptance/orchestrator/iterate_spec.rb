require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestIterate
    extend LightService::Orchestrator

    def self.run(context)
      with(context).reduce([
                             iterate(:numbers, [
                                       TestDoubles::AddOneAction
                                     ])
                           ])
    end

    def self.run_single(context)
      with(context).reduce([
                             iterate(:numbers, TestDoubles::AddOneAction)
                           ])
    end
  end

  it 'reduces each item of a collection and singularizes the collection key' do
    result = TestIterate.run(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'accepts a single action or organizer' do
    result = TestIterate.run_single(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end
end
