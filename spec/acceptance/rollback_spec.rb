require 'spec_helper'

class RollbackOrganizer
  extend LightService::Organizer

  def self.for(number)
    with(:number => number).reduce(
      AddsOneWithRollbackAction,
      AddsTwoWithRollbackAction,
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

class AddsTwoWithRollbackAction
  include LightService::Action
  expects :number

  executed do |context|
    context.number += 2
  end

  rolled_back do |context|
    context.number -= 2
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

describe RollbackOrganizer do
  it "Adds 1, 2, 3 to 1 and rolls back " do
    result = RollbackOrganizer.for 1
    number = result.fetch(:number)

    expect(result).to be_failure
    expect(result.message).to eq("I did not like this!")
    expect(number).to eq(1)
  end
end
