require 'spec_helper'

class AdditionOrganizer
  include LightService::Organizer

  def self.add_numbers(number)
    with(:number => number).reduce(
      AddsOneAction,
      AddsTwoAction,
      AddsThreeAction
    )
  end
end

class AddsOneAction
  include LightService::Action
  expects :number
  promises :number

  executed do |context|
    context.number += 1
  end
end

class AddsTwoAction
  include LightService::Action
  expects :number
  promises :number

  executed do |context|
    context.number += 2
  end
end

class AddsThreeAction
  include LightService::Action
  expects :number
  promises :product

  executed do |context|
    context.product = context.number + 3
  end
end

describe AdditionOrganizer do
  it "Adds 1 2 3 and through to 1" do
    result = AdditionOrganizer.add_numbers 1
    number = result.fetch(:product)

    expect(number).to eq(7)
  end
end
