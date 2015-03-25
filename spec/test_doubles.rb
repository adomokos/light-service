# A collection of Action and Organizer dummies used in specs

module TestDoubles
  class AddsTwoActionWithFetch
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
      if context.milk == :very_hot
        context.fail!("Can't make a latte from a milk that's very hot!")
        next context
      end

      if context.milk == :super_hot
        context.fail_with_rollback!("Can't make a latte from a milk that's super hot!")
        next context
      end

      context[:latte] = "#{context.coffee} - with lots of #{context.milk}"

      if context.milk == "5%"
        context.skip_all!("Can't make a latte with a fatty milk like that!")
        next context
      end
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

  class MakesTeaAndCappuccino
    include LightService::Organizer

    def self.call(tea, milk, coffee)
      with(:tea => tea, :milk => milk, :coffee => coffee)
          .reduce(TestDoubles::MakesTeaWithMilkAction,
                  TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwo
    include LightService::Organizer

    def self.call(milk, coffee)
      with(:milk => milk, :coffee => coffee)
          .reduce(TestDoubles::AddsTwoActionWithFetch,
                  TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwoAndFails
    include LightService::Organizer

    def self.call(coffee, this_hot = :very_hot)
      with(:milk => this_hot, :coffee => coffee)
          .reduce(TestDoubles::MakesLatteAction,
                  TestDoubles::AddsTwoActionWithFetch)

    end
  end

  class MakesCappuccinoSkipsAddsTwo
    include LightService::Organizer

    def self.call(coffee)
      with(:milk => "5%", :coffee => coffee)
          .reduce(TestDoubles::MakesLatteAction,
                  TestDoubles::AddsTwoActionWithFetch)

    end
  end

  class AdditionOrganizer
    extend LightService::Organizer

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

  class MakesTeaExpectingReservedKey
    include LightService::Action
    expects :tea, :message

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaExpectingMultipleReservedKeys
    include LightService::Action
    expects :tea, :message, :error_code, :current_action

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaPromisingReservedKey
    include LightService::Action
    expects :tea
    promises :product, :message

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaPromisingMultipleReservedKeys
    include LightService::Action
    expects :tea
    promises :product, :message, :error_code, :current_action

    executed do |context|
      context.product = context.number + 3
    end
  end
end
