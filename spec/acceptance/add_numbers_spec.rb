require 'spec_helper'

class Organizer
  extend LightService::Organizer

  def self.add_number(number)
    with(number: number).reduce \
      [
        AddsOneAction,
        AddsTwoAction,
        AddsThreeAction
      ]
  end
end

class AddsOneAction
  include LightService::Action

  executed do |context|
    number = context.fetch :number
    number += 1

    context[:number] = number
  end
end

class AddsTwoAction
  include LightService::Action

  executed do |context|
    number = context.fetch :number
    number += 2

    context[:number] = number
  end
end

class AddsThreeAction
  include LightService::Action

  executed do |context|
    number = context.fetch :number
    number += 3

    context[:number] = number
  end
end

describe Organizer do
  it "Adds 1 2 3 and through to 1" do
    result = Organizer.add_number 1
    result.fetch(:number).should == 7
  end
end
