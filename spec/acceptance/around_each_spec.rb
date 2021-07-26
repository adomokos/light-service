require 'spec_helper'
require 'test_doubles'

describe 'Executing arbitrary code around each action' do
  it 'can be used to log data' do
    context = { :number => 0, :logger => TestDoubles::TestLogger.new }

    result = TestDoubles::AroundEachOrganizer.call(context)

    expect(result.fetch(:number)).to eq(2)
    expect(result[:logger].logs).to eq(
      [{
        :action => TestDoubles::AddsTwoActionWithFetch,
        :before => 0,
        :after => 2
      }]
    )
  end

  it 'does not work reduce if organizer' do
    context = { :number => 1, :logger => TestDoubles::TestLogger.new }

    result = TestDoubles::AroundEachWithReduceIfOrganizer.call(context)

    expect(result.fetch(:number)).to eq(7)
    expect(result[:logger].logs).to eq(
      [
        { :action => TestDoubles::AddsOneAction, :before => 1, :after => 2 },
        { :action => TestDoubles::AddsTwoAction, :before => 2, :after => 4 }, # reduce_if doesn't work correctly with around each
        { :action => TestDoubles::AddsThreeAction, :before => 4, :after => 7 }
      ]
    )
  end
end
