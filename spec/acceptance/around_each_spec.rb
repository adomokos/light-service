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
end
