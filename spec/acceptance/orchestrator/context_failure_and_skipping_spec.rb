require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  include_context 'expect orchestrator warning'

  class OrchestratorTestSkipState
    extend LightService::Orchestrator
    def self.run_skip_before
      with(:number => 1).reduce([
                                  TestDoubles::SkipAllAction,
                                  reduce_until(->(ctx) { ctx.number == 3 },
                                               TestDoubles::AddsOneAction)
                                ])
    end

    def self.run_skip_after
      with(:number => 1).reduce([
                                  TestDoubles::AddsOneAction,
                                  reduce_until(->(ctx) { ctx.number == 3 }, [
                                                 TestDoubles::AddsOneAction
                                               ]),
                                  TestDoubles::SkipAllAction,
                                  TestDoubles::AddsOneAction
                                ])
    end

    def self.run_failure
      with(:number => 1).reduce([
                                  TestDoubles::FailureAction,
                                  reduce_until(->(ctx) { ctx[:number] == 3 },
                                               TestDoubles::AddsOneAction),
                                  TestDoubles::AddsOneAction
                                ])
    end
  end

  it 'skips all the rest of the actions' do
    result = OrchestratorTestSkipState.run_skip_before

    expect(result).to be_success
    expect(result[:number]).to eq(1)
  end

  it 'skips after an action in nested context' do
    result = OrchestratorTestSkipState.run_skip_after

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'respects failure across all nestings' do
    result = OrchestratorTestSkipState.run_failure

    expect(result).to be_failure
    expect(result[:number]).to eq(1)
  end
end
