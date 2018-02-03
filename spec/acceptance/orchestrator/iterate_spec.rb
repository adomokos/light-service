require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  include_context 'expect orchestrator warning'

  class OrchestratorTestIterate
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

  let(:empty_context) { LightService::Context.make }

  it 'reduces each item of a collection and singularizes the collection key' do
    result = OrchestratorTestIterate.run(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'accepts a single action or organizer' do
    result = OrchestratorTestIterate.run_single(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'will not iterate over a failed context' do
    empty_context.fail!('Something bad happened')

    result = OrchestratorTestIterate.run(empty_context)

    expect(result).to be_failure
  end

  it 'does not iterate over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = OrchestratorTestIterate.run(empty_context)
    expect(result).to be_success
  end
end
