# A collection of Action and Organizer dummies used in specs

module TestDoubles
  class RollbackAction
    extend LightService::Action
    executed(&:fail_with_rollback!)
  end

  class RaiseErrorAction
    extend LightService::Action
    executed do |_ctx|
      raise 'A problem has occured.'
    end
  end

  class RaiseAnotherErrorAction
    extend LightService::Action
    executed do |_ctx|
      raise 'More problems'
    end
  end

  class SkipAllAction
    extend LightService::Action
    executed(&:skip_remaining!)
  end

  class FailureAction
    extend LightService::Action
    executed(&:fail!)
  end

  class AddOneAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |ctx|
      ctx.number += 1
      ctx.message = 'Added 1'
    end
  end

  class AddTwoOrganizer
    extend LightService::Organizer
    def self.call(context)
      with(context).reduce([AddOneAction, AddOneAction])
    end
  end

  class AroundEachNullHandler
    def self.call(_action, _context)
      yield
    end
  end

  class TestLogger
    attr_accessor :logs
    def initialize
      @logs = []
    end
  end

  class AroundEachLoggerHandler
    def self.call(context)
      before_number = context[:number]
      result = yield

      context[:logger].logs << {
        :action => context.current_action,
        :before => before_number,
        :after => result[:number]
      }

      result
    end
  end

  class AroundEachOrganizer
    extend LightService::Organizer
    def self.call(action_arguments)
      with(action_arguments)
        .around_each(AroundEachLoggerHandler)
        .reduce([AddsTwoActionWithFetch])
    end
  end

  class AddsTwoActionWithFetch
    extend LightService::Action

    executed do |context|
      number = context.fetch(:number, 0)
      context[:number] = number + 2
    end
  end

  class AnAction; end
  class AnotherAction; end

  class AnOrganizer
    extend LightService::Organizer

    def self.call(action_arguments)
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
    extend LightService::Action
    expects :tea, :milk
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk}"
    end
  end

  class MultipleExpectsAction
    extend LightService::Action
    expects :tea
    expects :milk, :chocolate
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk}"\
                         " - with #{context.chocolate}"
    end
  end

  class MakesCappuccinoAction
    extend LightService::Action
    expects :coffee, :milk
    promises :cappuccino
  end

  class MakesLatteAction
    extend LightService::Action
    expects :coffee, :milk
    promises :latte

    executed do |context|
      if context.milk == :very_hot
        context.fail!("Can't make a latte from a milk that's very hot!")
        next context
      end

      if context.milk == :super_hot
        error_message = "Can't make a latte from a milk that's super hot!"
        context.fail_with_rollback!(error_message)
        next context
      end

      context[:latte] = "#{context.coffee} - with lots of #{context.milk}"

      if context.milk == "5%"
        msg = "Can't make a latte with a fatty milk like that!"
        context.skip_remaining!(msg)
        next context
      end
    end
  end

  class MultiplePromisesAction
    extend LightService::Action
    expects :coffee, :milk
    promises :cappuccino
    promises :latte

    executed do |context|
      context.cappuccino = "Cappucino needs #{context.coffee} and a little milk"
      context.latte = "Latte needs #{context.coffee} and a lot of milk"
    end
  end

  class MakesTeaAndCappuccino
    extend LightService::Organizer

    def self.call(tea, milk, coffee)
      with(:tea => tea, :milk => milk, :coffee => coffee)
        .reduce(TestDoubles::MakesTeaWithMilkAction,
                TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwo
    extend LightService::Organizer

    def self.call(milk, coffee)
      with(:milk => milk, :coffee => coffee)
        .reduce(TestDoubles::AddsTwoActionWithFetch,
                TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwoAndFails
    extend LightService::Organizer

    def self.call(coffee, this_hot = :very_hot)
      with(:milk => this_hot, :coffee => coffee)
        .reduce(TestDoubles::MakesLatteAction,
                TestDoubles::AddsTwoActionWithFetch)
    end
  end

  class MakesCappuccinoSkipsAddsTwo
    extend LightService::Organizer

    def self.call(coffee)
      with(:milk => "5%", :coffee => coffee)
        .reduce(TestDoubles::MakesLatteAction,
                TestDoubles::AddsTwoActionWithFetch)
    end
  end

  class AdditionOrganizer
    extend LightService::Organizer

    def self.call(number)
      with(:number => number).reduce(
        AddsOneAction,
        AddsTwoAction,
        AddsThreeAction
      )
    end
  end

  class AddsOneAction
    extend LightService::Action
    expects :number
    promises :number

    executed do |context|
      context.number += 1
    end
  end

  class AddsTwoAction
    extend LightService::Action
    expects :number

    executed do |context|
      context.number += 2
    end
  end

  class AddsThreeAction
    extend LightService::Action
    expects :number
    promises :product

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaExpectingReservedKey
    extend LightService::Action
    expects :tea, :message

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaExpectingMultipleReservedKeys
    extend LightService::Action
    expects :tea, :message, :error_code, :current_action

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaPromisingReservedKey
    extend LightService::Action
    expects :tea
    promises :product, :message

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaPromisingMultipleReservedKeys
    extend LightService::Action
    expects :tea
    promises :product, :message, :error_code, :current_action

    executed do |context|
      context.product = context.number + 3
    end
  end

  class MakesTeaPromisingKeyButRaisesException
    extend LightService::Action
    promises :product

    executed do |context|
      context.product = make_product
    end

    def self.make_product
      raise "Fail"
    end
    private_class_method :make_product
  end

  class PromisesPromisedKeyAction
    extend LightService::Action

    promises :promised_key

    executed do |ctx|
      ctx.promised_key = "promised_key"
    end
  end

  class ExpectsExpectedKeyAction
    extend LightService::Action

    expects :expected_key
    promises :final_key

    executed do |ctx|
      ctx.final_key = ctx.expected_key
    end
  end
end
