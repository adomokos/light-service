# A collection of Action and Organizer dummies used in specs

module LightService
  class AddTwoAction
    include LightService::Action

    executed do |context|
      number = context.fetch(:number, 0)
      context[:number] = number + 2
    end
  end

  class AnAction; end
  class AnotherAction; end

  class AnOrganizer
    include LightService::Organizer

    def self.do_something(action_arguments)
      with(action_arguments).reduce([AnAction, AnotherAction])
    end

    def self.do_something_with_no_actions(action_arguments)
      with(action_arguments).reduce
    end

    def self.do_something_with_no_starting_context
      reduce([AnAction, AnotherAction])
    end
  end

  class DummyActionForKeysToExpect
    include LightService::Action
    expects :tea, :milk
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk}"
    end
  end

  class DummyActionWithMultipleExpects
    include LightService::Action
    expects :tea
    expects :milk, :chocolate
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk} - with #{context.chocolate}"
    end
  end

  class DummyActionForKeysToPromise
    include LightService::Action
    expects :tea, :milk
    promises :milk_tea
  end

  class DummyActionWithMultiplePromises
    include LightService::Action
    expects :coffee
    promises :cappuccino
    promises :latte

    executed do |context|
      context.cappuccino = "Cappucino needs #{context.coffee} and a little milk"
      context.latte = "Latte needs #{context.coffee} and a lot of milk"
    end
  end
end
