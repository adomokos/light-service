require 'spec_helper'

module IterateSpec
  class AddsOneWithRollbackAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      context.number += 1
    end

    rolled_back do |context|
      context.number -= 1
    end
  end

  class AddsTwoWithRollbackAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      context.number += 2
    end

    rolled_back do |context|
      context.number -= 2
    end
  end

  class FailsWithRollbackWhenReachesTwelve
    extend LightService::Action
    expects :number

    executed do |context|
      context.fail_with_rollback!("10 was reached, failing with rollback") \
        if context.number >= 12
    end
  end

  class TestIterate
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .reduce([iterate(:counters,
                         [AddsOneWithRollbackAction,
                          AddsTwoWithRollbackAction,
                          FailsWithRollbackWhenReachesTwelve])])
    end

    def self.call_single(context)
      with(context)
        .reduce([iterate(:counters,
                         AddsOneWithRollbackAction)])
    end
  end
end

RSpec.describe LightService::Organizer do
  let(:empty_context) { LightService::Context.make }

  it 'reduces each item of a collection and singularizes the collection key' do
    result = IterateSpec::TestIterate.call(:number => 1,
                                           :counters => [1, 2])

    expect(result).to be_success
    expect(result.number).to eq(7)
  end

  it 'rolls back the actions when it reaches 10' do
    result = IterateSpec::TestIterate.call(:number => 1,
                                           :counters => [1, 2, 3, 4])

    expect(result).to be_failure
    expect(result.number).to eq(1)
  end

  it 'accepts a single action or organizer' do
    result = IterateSpec::TestIterate.call_single(:number => 1,
                                                  :counters => [1, 2, 3, 4])

    expect(result).to be_success
    expect(result.number).to eq(5)
  end

  it "knows that it's being iterated from within an organizer" do
    result = IterateSpec::TestIterate.call(:number => 1,
                                           :counters => [1, 2, 3])

    expect(result.organized_by).to eq IterateSpec::TestIterate
  end

  it 'will not iterate over a failed context' do
    empty_context.fail!('Something bad happened')

    result = IterateSpec::TestIterate.call(empty_context)

    expect(result).to be_failure
  end

  it 'does not iterate over a skipped context' do
    empty_context.skip_remaining!('No more needed')

    result = IterateSpec::TestIterate.call(empty_context)
    expect(result).to be_success
  end
end
