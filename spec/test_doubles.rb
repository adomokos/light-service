# A collection of Action and Organizer dummies used in specs

module TestDoubles
  class AddsTwoAction
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

  class MakesTeaWithMilkAction
    include LightService::Action
    expects :tea, :milk
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk}"
    end
  end

  class MultipleExpectsAction
    include LightService::Action
    expects :tea
    expects :milk, :chocolate
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk} - with #{context.chocolate}"
    end
  end

  class MakesCappuccinoAction
    include LightService::Action
    expects :coffee, :milk
    promises :cappuccino
  end

  class MakesLatteAction
    include LightService::Action
    expects :coffee, :milk
    promises :latte

    executed do |context|
      context[:latte] = "#{context.coffee} - with lots of #{context.milk}"
    end
  end

  class MultiplePromisesAction
    include LightService::Action
    expects :coffee, :milk
    promises :cappuccino
    promises :latte

    executed do |context|
      context.cappuccino = "Cappucino needs #{context.coffee} and a little milk"
      context.latte = "Latte needs #{context.coffee} and a lot of milk"
    end
  end
end