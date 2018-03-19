require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  include_context 'expect orchestrator warning'

  class OrchestratorTestSkipState
    extend LightService::Orchestrator

    class FailureOrganizer
      extend LightService::Organizer

      def self.call(context)
        with(context).reduce(TestDoubles::FailureAction)
      end
    end

    def self.run_skip_before
      with(:number => 1)
        .reduce([
                  TestDoubles::SkipAllAction,
                  reduce_until(->(ctx) { ctx.number == 3 },
                               TestDoubles::AddOneAction)
                ])
    end

    def self.run_skip_after
      with(:number => 1)
        .reduce([
                  TestDoubles::AddOneAction,
                  reduce_until(->(ctx) { ctx.number == 3 }, [
                                 TestDoubles::AddOneAction
                               ]),
                  TestDoubles::SkipAllAction,
                  TestDoubles::AddOneAction
                ])
    end

    def self.run_failure
      with(:number => 1)
        .reduce([
                  TestDoubles::FailureAction,
                  reduce_until(->(ctx) { ctx[:number] == 3 },
                               TestDoubles::AddOneAction),
                  TestDoubles::AddOneAction
                ])
    end

    def self.run_failure_in_organizer
      with(:number => 1)
        .reduce([
                  TestDoubles::AddOneAction,
                  reduce_until(->(ctx) { ctx[:number] == 3 },
                               TestDoubles::AddOneAction),
                  FailureOrganizer,
                  TestDoubles::AddOneAction
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

  it 'stops processing when fails in an organizer' do
    result = TestSkipState.run_failure_in_organizer

    expect(result).to be_failure
    expect(result[:number]).to eq(3)
  end
end
