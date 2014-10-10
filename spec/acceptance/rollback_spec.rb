require 'spec_helper'
require 'test_doubles'

class RollbackOrganizer
  extend LightService::Organizer

  def self.for(number)
    with(:number => number).reduce(
      AddsOneWithRollbackAction,
      TestDoubles::AddsTwoAction,
      AddsThreeWithRollbackAction
    )
  end
end

class AddsOneWithRollbackAction
  include LightService::Action
  expects :number
  promises :number

  executed do |context|
    context.number += 1
  end

  rolled_back do |context|
    context.number -= 1
  end
end

class AddsThreeWithRollbackAction
  include LightService::Action
  expects :number

  executed do |context|
    context.number = context.number + 3

    context.fail_with_rollback!("I did not like this!")
  end

  rolled_back do |context|
    context.number -= 3
  end
end

class RollbackOrganizerWithNoRollback
  extend LightService::Organizer

  def self.for(number)
    with(:number => number).reduce(
      TestDoubles::AddsOneAction,
      TestDoubles::AddsTwoAction,
      AddsThreeWithNoRollbackAction
    )
  end
end

class AddsThreeWithNoRollbackAction
  include LightService::Action
  expects :number

  executed do |context|
    context.number = context.number + 3

    context.fail_with_rollback!("I did not like this!")
  end
end

describe RollbackOrganizer do
  it "Adds 1, 2, 3 to 1 and rolls back " do
    result = RollbackOrganizer.for 1
    number = result.fetch(:number)

    expect(result).to be_failure
    expect(result.message).to eq("I did not like this!")
    expect(number).to eq(3)
  end

  it "won't error out when actions don't define rollback" do
    result = RollbackOrganizerWithNoRollback.for 1
    number = result.fetch(:number)

    expect(result).to be_failure
    expect(result.message).to eq("I did not like this!")
    expect(number).to eq(7)
  end
end
