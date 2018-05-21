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

  class AddTwoOrganizer
    extend LightService::Organizer
    def self.call(context)
      with(context).reduce([AddsOneAction, AddsOneAction])
    end
  end

  class AroundEachNullHandler
    def self.call(_action)
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

  class NotExplicitlyReturningContextOrganizer
    extend LightService::Organizer

    def self.call(context)
      context[:foo] = [1, 2, 3]
    end
  end

  class NestingOrganizer
    extend LightService::Organizer

    def self.call(context)
      with(context).reduce([NotExplicitlyReturningContextOrganizer, NestedAction])
    end
  end

  class NestedAction
    extend LightService::Action

    expects :foo

    executed do |context|
      context[:bar] = context.foo
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
      end

      if context.milk == :super_hot
        error_message = "Can't make a latte from a milk that's super hot!"
        context.fail_with_rollback!(error_message)
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
      with(:number => number).reduce(actions)
    end

    def self.actions
      [
        AddsOneAction,
        AddsTwoAction,
        AddsThreeAction
      ]
    end
  end

  class ExtraArgumentAdditionOrganizer
    extend LightService::Organizer

    def self.call(number, another_number)
      with(:number => number + another_number).reduce(actions)
    end

    def self.actions
      [
        AddsOneAction,
        AddsTwoAction,
        AddsThreeAction
      ]
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

    executed do |context|
      context.number += 3
    end
  end

  class IterateOrganizer
    extend LightService::Organizer

    def self.call(ctx)
      with(ctx).reduce(actions)
    end

    def self.actions
      [
        AddsOneIteratesAction,
        iterate(:numbers, [
                  AddsTwoAction,
                  AddsThreeAction
                ])
      ]
    end
  end

  class AddsOneIteratesAction
    extend LightService::Action
    expects :numbers
    promises :numbers

    executed do |context|
      context.numbers = context.numbers.map { |n| n + 1 }
    end
  end

  class CallbackOrganizer
    extend LightService::Organizer

    def self.call(ctx)
      with(ctx).reduce(actions)
    end

    def self.actions
      [
        AddsOneAction,
        with_callback(AddTenCallbackAction, [
                        AddsTwoAction,
                        AddsThreeAction
                      ])
      ]
    end
  end

  class AddTenCallbackAction
    extend LightService::Action
    expects :number, :callback

    executed do |context|
      context.number += 10
      context.number =
        context.callback.call(context).fetch(:number)
    end
  end

  class ReduceUntilOrganizer
    extend LightService::Organizer

    def self.call(ctx)
      with(ctx).reduce(actions)
    end

    def self.actions
      [
        AddsOneAction,
        reduce_until(->(ctx) { ctx.number > 3 }, [
                       AddsTwoAction,
                       AddsThreeAction
                     ])
      ]
    end
  end

  class ReduceIfOrganizer
    extend LightService::Organizer

    def self.call(ctx)
      with(ctx).reduce(actions)
    end

    def self.actions
      [
        AddsOneAction,
        reduce_if(->(ctx) { ctx.number > 1 }, [
                    AddsTwoAction,
                    AddsThreeAction
                  ])
      ]
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

  class NullAction
    extend LightService::Action

    executed { |_ctx| }
  end

  class TestIterate
    extend LightService::Organizer

    def self.call(context)
      with(context)
        .reduce([iterate(:counters,
                         [TestDoubles::AddsOneAction])])
    end

    def self.call_single(context)
      with(context)
        .reduce([iterate(:counters,
                         TestDoubles::AddsOneAction)])
    end
  end

  class TestWithCallback
    extend LightService::Organizer

    def self.call(context = {})
      with(context).reduce(actions)
    end

    def self.actions
      [
        SetUpContextAction,
        with_callback(IterateCollectionAction,
                      [IncrementCountAction,
                       AddToTotalAction])
      ]
    end
  end

  class SetUpContextAction
    extend LightService::Action
    promises :numbers, :counter, :total

    executed do |ctx|
      ctx.numbers = [1, 2, 3]
      ctx.counter = 0
      ctx.total = 0
    end
  end

  class IterateCollectionAction
    extend LightService::Action
    expects :numbers, :callback
    promises :number

    executed do |ctx|
      ctx.numbers.each do |number|
        ctx.number = number
        ctx.callback.call(ctx)
      end
    end
  end

  class IncrementCountAction
    extend LightService::Action
    expects :counter

    executed do |ctx|
      ctx.counter = ctx.counter + 1
    end
  end

  class AddToTotalAction
    extend LightService::Action
    expects :number, :total

    executed do |ctx|
      ctx.total += ctx.number
    end
  end
end
