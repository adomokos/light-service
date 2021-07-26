require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  include_context 'expect orchestrator warning'

  class OrchestratorTestExecute
    extend LightService::Orchestrator

    def self.run(context)
      with(context).reduce(steps)
    end

    def self.steps
      [
        TestDoubles::AddsOneAction,
        execute(->(ctx) { ctx.number += 1 }),
        execute(->(ctx) { ctx[:something] = 'hello' }),
        TestDoubles::AddsOneAction
      ]
    end
  end

  let(:empty_context) { LightService::Context.make }

  before { record_events }

  it 'calls the lambda in the execute block using the context' do
    result = OrchestratorTestExecute.run(:number => 0)

    expect(result).to be_success
    expect(result.number).to eq(3)
    expect(result[:something]).to eq('hello')
  end

  it 'will not execute a failed context' do
    empty_context.fail!('Something bad happened')

    result = OrchestratorTestExecute.run(empty_context)

    expect(result).to be_failure
  end

  it 'does not execute over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = OrchestratorTestExecute.run(empty_context)
    expect(result).to be_success
  end

  it 'emits event' do
    OrchestratorTestExecute.run(:number => 0)
    expect(events.count).to eq(2)
    expect(events[0].payload[:name]).to eq('TestDoubles::AddsOneAction')
    expect(events[1].payload[:name]).to eq('TestDoubles::AddsOneAction')
  end

  private

  attr_reader :events

  def record_events
    @events = []
    ActiveSupport::Notifications.subscribe('action.exec') do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end
end
