require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  let(:empty_context) { LightService::Context.make }

  it 'reduces each item of a collection and singularizes the collection key' do
    result = TestDoubles::TestIterate.call(:number => 1,
                                           :counters => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'accepts a single action or organizer' do
    result = TestDoubles::TestIterate.call_single(:number => 1,
                                                  :counters => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it "knows that it's being iterated from within an organizer" do
    result = TestDoubles::TestIterate.call(:number => 1, :counters => [1, 2, 3, 4])

    expect(result.organized_by).to eq TestDoubles::TestIterate
  end

  it 'will not iterate over a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestDoubles::TestIterate.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not iterate over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestDoubles::TestIterate.call(empty_context)
    expect(result).to be_success
  end
end
