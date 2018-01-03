require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestIterate
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .reduce([iterate(:numbers,
                         [TestDoubles::AddOneAction])])
    end

    def self.call_single(context)
      with(context)
        .reduce([iterate(:numbers,
                         TestDoubles::AddOneAction)])
    end
  end

  let(:empty_context) { LightService::Context.make }

  it 'reduces each item of a collection and singularizes the collection key' do
    result = TestIterate.call(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'accepts a single action or organizer' do
    result = TestIterate.call_single(:numbers => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it 'will not iterate over a failed context' do
    empty_context.fail!('Something bad happened')

    result = TestIterate.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not iterate over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = TestIterate.call(empty_context)
    expect(result).to be_success
  end
end
