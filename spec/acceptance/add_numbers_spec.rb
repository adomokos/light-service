require 'spec_helper'
require 'test_doubles'

describe TestDoubles::AdditionOrganizer do
  it "Adds 1 2 3 and through to 1" do
    result = TestDoubles::AdditionOrganizer.add_numbers 1
    number = result.fetch(:product)

    expect(number).to eq(7)
  end
end
