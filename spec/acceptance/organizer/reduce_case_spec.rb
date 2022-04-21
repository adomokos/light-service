require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Organizer do
  class TestReduceCase
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce(actions)
    end

    def self.actions
      [
        reduce_case(
          :value => :incr_num,
          :when => {
            :one => [TestDoubles::AddsOneAction],
            :two => [TestDoubles::AddsTwoAction],
            :three => [TestDoubles::AddsThreeAction]
          },
          :else => [TestDoubles::FailureAction]
        )
      ]
    end
  end

  it 'adds one if the incr_num is one' do
    result = TestReduceCase.call(:number => 0, :incr_num => :one)

    expect(result).to be_success
    expect(result[:number]).to eq(1)
  end

  it 'adds two if the incr_num is two' do
    result = TestReduceCase.call(:number => 0, :incr_num => :two)

    expect(result).to be_success
    expect(result[:number]).to eq(2)
  end

  it 'adds three if the incr_num is three' do
    result = TestReduceCase.call(:number => 0, :incr_num => :three)

    expect(result).to be_success
    expect(result[:number]).to eq(3)
  end

  it 'will fail if the incr_num is neither one, two, or three' do
    result = TestReduceCase.call(:number => 0, :incr_num => :four)

    expect(result).to be_failure
  end
end
