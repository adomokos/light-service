require 'spec_helper'
require 'test_doubles'

RSpec.describe TestDoubles::AdditionOrganizer do
  it 'Adds 1, 2 and 3 to the initial value of 1' do
    result = TestDoubles::AdditionOrganizer.call(1)
    number = result.fetch(:number)

    expect(number).to eq(7)
  end
end
