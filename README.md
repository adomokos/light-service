![LightService](https://raw.githubusercontent.com/adomokos/light-service/master/resources/light-service.png)

[![Gem Version](https://img.shields.io/gem/v/light-service.svg)](https://rubygems.org/gems/light-service)
[![Build Status](https://secure.travis-ci.org/adomokos/light-service.png)](http://travis-ci.org/adomokos/light-service)
[![Code Climate](https://codeclimate.com/github/adomokos/light-service.png)](https://codeclimate.com/github/adomokos/light-service)
[![Dependency Status](https://beta.gemnasium.com/badges/github.com/adomokos/light-service.svg)](https://beta.gemnasium.com/projects/github.com/adomokos/light-service)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

<br><br>

![Orchestrators-Deprecated](resources/orchestrators_deprecated.svg)
<br>Version 0.9.0 deprecates Orchestrators and moves all their functionalities into Organizers. Please check out [this PR](https://github.com/adomokos/light-service/pull/132) to see the changes.

<br>

## Table of Content
* [Why LightService?](#why-lightservice)
* [Stopping the Series of Actions](#stopping-the-series-of-actions)
    * [Failing the Context](#failing-the-context)
    * [Skipping the Rest of the Actions](#skipping-the-rest-of-the-actions)
* [Benchmarking Actions with Around Advice](#benchmarking-actions-with-around-advice)
* [Before and After Action Hooks](#before-and-after-action-hooks)
* [Key Aliases](#key-aliases)
* [Logging](#logging)
* [Error Codes](#error-codes)
* [Action Rollback](#action-rollback)
* [Localizing Messages](#localizing-messages)
* [Orchestrator Logic in Organizers](#orchestrator-logic-in-organizers)
* [ContextFactory for Faster Action Testing](#contextfactory-for-faster-action-testing)


## Why LightService?

What do you think of this code?

```ruby
class TaxController < ApplicationController
  def update
    @order = Order.find(params[:id])
    tax_ranges = TaxRange.for_region(order.region)

    if tax_ranges.nil?
      render :action => :edit, :error => "The tax ranges were not found"
      return # Avoiding the double render error
    end

    tax_percentage = tax_ranges.for_total(@order.total)

    if tax_percentage.nil?
      render :action => :edit, :error => "The tax percentage  was not found"
      return # Avoiding the double render error
    end

    @order.tax = (@order.total * (tax_percentage/100)).round(2)

    if @order.total_with_tax > 200
      @order.provide_free_shipping!
    end

    redirect_to checkout_shipping_path(@order), :notice => "Tax was calculated successfully"
  end
end
```

This controller violates [SRP](http://en.wikipedia.org/wiki/Single_responsibility_principle) all over.
Also, imagine what it would take to test this beast.
You could move the tax_percentage finders and calculations into the tax model,
but then you'll make your model logic heavy.

This controller does 3 things in order:
* Looks up the tax percentage based on order total
* Calculates the order tax
* Provides free shipping if the total with tax is greater than $200

The order of these tasks matters: you can't calculate the order tax without the percentage.
Wouldn't it be nice to see this instead?

```ruby
(
  LooksUpTaxPercentage,
  CalculatesOrderTax,
  ChecksFreeShipping
)
```

This block of code should tell you the "story" of what's going on in this workflow.
With the help of LightService you can write code this way. First you need an organizer object that sets up the actions in order
and executes them one-by-one. Then you need to create the actions with one method (that will do only one thing).

This is how the organizer and actions interact with each other:

![LightService](https://raw.githubusercontent.com/adomokos/light-service/master/resources/organizer_and_actions.png)

```ruby
class CalculatesTax
  extend LightService::Organizer

  def self.call(order)
    with(:order => order).reduce(
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
      )
  end
end

class LooksUpTaxPercentageAction
  extend LightService::Action
  expects :order
  promises :tax_percentage

  executed do |context|
    tax_ranges = TaxRange.for_region(context.order.region)
    context.tax_percentage = 0

    next context if object_is_nil?(tax_ranges, context, 'The tax ranges were not found')

    context.tax_percentage = tax_ranges.for_total(context.order.total)

    next context if object_is_nil?(context.tax_percentage, context, 'The tax percentage was not found')
  end

  def self.object_is_nil?(object, context, message)
    if object.nil?
      context.fail!(message)
      return true
    end

    false
  end
end

class CalculatesOrderTaxAction
  extend ::LightService::Action
  expects :order, :tax_percentage

  # I am using ctx as an abbreviation for context
  executed do |ctx|
    order = ctx.order
    order.tax = (order.total * (ctx.tax_percentage/100)).round(2)
  end

end

class ProvidesFreeShippingAction
  extend LightService::Action
  expects :order

  executed do |ctx|
    if ctx.order.total_with_tax > 200
      ctx.order.provide_free_shipping!
    end
  end
end
```

And with all that, your controller should be super simple:

```ruby
class TaxController < ApplicationContoller
  def update
    @order = Order.find(params[:id])

    service_result = CalculatesTax.for_order(@order)

    if service_result.failure?
      render :action => :edit, :error => service_result.message
    else
      redirect_to checkout_shipping_path(@order), :notice => "Tax was calculated successfully"
    end

  end
end
```
I gave a [talk at RailsConf 2013](http://www.adomokos.com/2013/06/simple-and-elegant-rails-code-with.html) on
simple and elegant Rails code where I told the story of how LightService was extracted from the projects I had worked on.



## Stopping the Series of Actions
When nothing unexpected happens during the organizer's call, the returned `context` will be successful. Here is how you can check for this:
```ruby
class SomeController < ApplicationController
  def index
    result_context = SomeOrganizer.call(current_user.id)

    if result_context.success?
      redirect_to foo_path, :notice => "Everything went OK! Thanks!"
    else
      flash[:error] = result_context.message
      render :action => "new"
    end
  end
end
```
However, sometimes not everything will play out as you expect it. An external API call might not be available or some complex business logic will need to stop the processing of the Series of Actions.
You have two options to stop the call chain:

1. Failing the context
2. Skipping the rest of the actions

### Failing the Context
When something goes wrong in an action and you want to halt the chain, you need to call `fail!` on the context object. This will push the context in a failure state (`context.failure? # will evalute to true`).
The context's `fail!` method can take an optional message argument, this message might help describing what went wrong.
In case you need to return immediately from the point of failure, you have to do that by calling `next context`.

In case you want to fail the context and stop the execution of the executed block, use the `fail_and_return!('something went wrong')` method.
This will immediately leave the block, you don't need to call `next context` to return from the block.

Here is an example:
```ruby
class SubmitsOrderAction
  extend LightService::Action
  expects :order, :mailer

  executed do |context|
    unless context.order.submit_order_successful?
      context.fail_and_return!("Failed to submit the order")
    end

    # This won't be executed
    context.mailer.send_order_notification!
  end
end
```
![fail-actions](https://raw.githubusercontent.com/adomokos/light-service/master/resources/fail_actions.png)

In the example above the organizer called 4 actions. The first 2 actions got executed successfully. The 3rd had a failure, that pushed the context into a failure state and the 4th action was skipped.

### Skipping the rest of the actions
You can skip the rest of the actions by calling `context.skip_remaining!`. This behaves very similarly to the above-mentioned `fail!` mechanism, except this will not push the context into a failure state.
A good use case for this is executing the first couple of action and based on a check you might not need to execute the rest.
Here is an example of how you do it:
```ruby
class ChecksOrderStatusAction
  extend LightService::Action
  expects :order

  executed do |context|
    if context.order.send_notification?
      context.skip_remaining!("Everything is good, no need to execute the rest of the actions")
    end
  end
end
```
![skip-actions](https://raw.githubusercontent.com/adomokos/light-service/master/resources/skip_actions.png)

In the example above the organizer called 4 actions. The first 2 actions got executed successfully. The 3rd decided to skip the rest, the 4th action was not invoked. The context was successful.


## Benchmarking Actions with Around Advice
Benchmarking your action is needed when you profile the series of actions. You could add benchmarking logic to each and every action, however, that would blur the business logic you have in your actions.

Take advantage of the organizer's `around_each` method, which wraps the action calls as its reducing them in order.

Check out this example:

```ruby
class LogDuration
  def self.call(action, context)
    start_time = Time.now
    result = yield
    duration = Time.now - start_time
    LightService::Configuration.logger.info(
      :action   => action,
      :duration => duration
    )

    result
  end
end

class CalculatesTax
  extend LightService::Organizer

  def self.call(order)
    with(:order => order).around_each(LogDuration).reduce(
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
      )
  end
end
```

Any object passed into `around_each` must respond to #call with two arguments: the action name and the context it will execute with. It is also passed a block, where LightService's action execution will be done in, so the result must be returned. While this is a little work, it also gives you before and after state access to the data for any auditing and/or checks you may need to accomplish.

## Before and After Action Hooks

In case you need to inject code right before and after the actions are executed, you can use the `before_actions` and `after_actions` hooks. It accepts one or multiple lambdas that the Action implementation will invoke. This addition to LightService is a great way to decouple instrumentation from business logic.

Consider this code:

```ruby
class SomeOrganizer
  extend LightService::Organizer

  def call(ctx)
    with(ctx).reduce(actions)
  end

  def actions
    OneAction,
    TwoAction,
    ThreeAction
  end
end

class TwoAction
  extend LightService::Action
  expects :user, :logger

  executed do |ctx|
    # Logging information
    if ctx.user.role == 'admin'
       ctx.logger.info('admin is doing something')
    end

    ctx.user.do_something
  end
end
```

The logging logic makes `TwoAction` more complex, there is more code for logging than for business logic.

You have two options to decouple instrumentation from real logic with `before_actions` and `after_actions` hooks:

1. Declare your hooks in the Organizer
2. Attach hooks to the Organizer from the outside

This is how you can declaratively add before and after hooks to the Organizer:

```ruby
class SomeOrganizer
  extend LightService::Organizer
  before_actions (lambda do |ctx|
                           if ctx.current_action == TwoAction
                             return unless ctx.user.role == 'admin'
                             ctx.logger.info('admin is doing something')
                           end
                         end)
  after_actions (lambda do |ctx|
                          if ctx.current_action == TwoAction
                            return unless ctx.user.role == 'admin'
                            ctx.logger.info('admin is DONE doing something')
                          end
                        end)

  def call(ctx)
    with(ctx).reduce(actions)
  end

  def actions
    OneAction,
    TwoAction,
    ThreeAction
  end
end

class TwoAction
  extend LightService::Action
  expects :user

  executed do |ctx|
    ctx.user.do_something
  end
end
```

Note how the action has no logging logic after this change. Also, you can target before and after action logic for specific actions, as the `ctx.current_action` will have the class name of the currently processed action. In the example above, logging will occur only for `TwoAction` and not for `OneAction` or `ThreeAction`.

Here is how you can declaratively add `before_hooks` or `after_hooks` to your Organizer from the outside:

```ruby
SomeOrganizer.before_actions =
  lambda do |ctx|
    if ctx.current_action == TwoAction
      return unless ctx.user.role == 'admin'
      ctx.logger.info('admin is doing something')
    end
  end
```

These ideas are originally from Aspect Oriented Programming, read more about them [here](https://en.wikipedia.org/wiki/Aspect-oriented_programming).

## Expects and Promises
The `expects` and `promises` macros are rules for the inputs/outputs of an action.
`expects` describes what keys it needs to execute, and `promises` makes sure the keys are in the context after the
action is reduced. If either of them are violated, a custom exception is thrown.

This is how it's used:
```ruby
class FooAction
  extend LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    baz = context.fetch :baz

    bar = baz + 2
    context[:bar] = bar
  end
end
```

The `expects` macro does a bit more for you: it pulls the value with the expected key from the context, and
makes it available to you through a reader. You can refactor the action like this:

```ruby
class FooAction
  extend LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    bar = context.baz + 2
    context[:bar] = bar
  end
end
```

The `promises` macro will not only check if the context has the promised keys, it also sets it for you in the context if
you use the accessor with the same name. The code above can be further simplified:

```ruby
class FooAction
  extend LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    context.bar = context.baz + 2
  end
end
```

Take a look at [this spec](spec/action_expects_and_promises_spec.rb) to see the refactoring in action.

## Key Aliases
The `aliases` macro sets up pairs of keys and aliases in an organizer. Actions can access the context using the aliases.

This allows you to put together existing actions from different sources and have them work together without having to modify their code. Aliases will work with or without action `expects`.

Say for example you have actions `AnAction` and `AnotherAction` that you've used in previous projects.  `AnAction` provides `:my_key` but `AnotherAction` needs to use that value but expects `:key_alias`.  You can use them together in an organizer like so:

```ruby
class AnOrganizer
  extend LightService::Organizer

  aliases :my_key => :key_alias

  def self.call(order)
    with(:order => order).reduce(
        AnAction,
        AnotherAction,
      )
  end
end

class AnAction
  extend LightService::Action
  promises :my_key

  executed do |context|
    context.my_key = "value"
  end
end

class AnotherAction
  extend LightService::Action
  expects :key_alias

  executed do |context|
    context.key_alias # => "value"
  end
end
```

## Logging
Enable LightService's logging to better understand what goes on within the series of actions,
what's in the context or when an action fails.

Logging in LightService is turned off by default. However, turning it on is simple. Add this line to your
project's config file:

```ruby
LightService::Configuration.logger = Logger.new(STDOUT)
```

You can turn off the logger by setting it to nil or `/dev/null`.

```ruby
LightService::Configuration.logger = Logger.new('/dev/null')
```

Watch the console while you are executing the workflow through the organizer. You should see something like this:

```bash
I, [DATE]  INFO -- : [LightService] - calling organizer <TestDoubles::MakesTeaAndCappuccino>
I, [DATE]  INFO -- : [LightService] -     keys in context: :tea, :milk, :coffee
I, [DATE]  INFO -- : [LightService] - executing <TestDoubles::MakesTeaWithMilkAction>
I, [DATE]  INFO -- : [LightService] -   expects: :tea, :milk
I, [DATE]  INFO -- : [LightService] -   promises: :milk_tea
I, [DATE]  INFO -- : [LightService] -     keys in context: :tea, :milk, :coffee, :milk_tea
I, [DATE]  INFO -- : [LightService] - executing <TestDoubles::MakesLatteAction>
I, [DATE]  INFO -- : [LightService] -   expects: :coffee, :milk
I, [DATE]  INFO -- : [LightService] -   promises: :latte
I, [DATE]  INFO -- : [LightService] -     keys in context: :tea, :milk, :coffee, :milk_tea, :latte
```

The log provides a blueprint of the series of actions. You can see what organizer is invoked, what actions
are called in what order, what do the expect and promise and most importantly what keys you have in the context
after each action is executed.

The logger logs its messages with "INFO" level. The exception to this is the event when an action fails the context.
That message is logged with "WARN" level:

```bash
I, [DATE]  INFO -- : [LightService] - calling organizer <TestDoubles::MakesCappuccinoAddsTwoAndFails>
I, [DATE]  INFO -- : [LightService] -     keys in context: :milk, :coffee
W, [DATE]  WARN -- : [LightService] - :-((( <TestDoubles::MakesLatteAction> has failed...
W, [DATE]  WARN -- : [LightService] - context message: Can't make a latte from a milk that's too hot!
```

The log message will show you what message was added to the context when the action pushed the
context into a failure state.

The event of skipping the rest of the actions is also captured by its logs:

```bash
I, [DATE]  INFO -- : [LightService] - calling organizer <TestDoubles::MakesCappuccinoSkipsAddsTwo>
I, [DATE]  INFO -- : [LightService] -     keys in context: :milk, :coffee
I, [DATE]  INFO -- : [LightService] - ;-) <TestDoubles::MakesLatteAction> has decided to skip the rest of the actions
I, [DATE]  INFO -- : [LightService] - context message: Can't make a latte with a fatty milk like that!
```

## Error Codes
You can add some more structure to your error handling by taking advantage of error codes in the context.
Normally, when something goes wrong in your actions, you fail the process by setting the context to failure:

```ruby
class FooAction
  extend LightService::Action

  executed do |context|
    context.fail!("I don't like what happened here.")
  end
end
```

However, you might need to handle the errors coming from your action pipeline differently.
Using an error code can help you check what type of expected error occurred in the organizer
or in the actions.

```ruby
class FooAction
  extend LightService::Action

  executed do |context|
    unless (service_call.success?)
      context.fail!("Service call failed", error_code: 1001)
    end

    # Do something else

    unless (entity.save)
      context.fail!("Saving the entity failed", error_code: 2001)
    end
  end
end
```

## Action Rollback
Sometimes your action has to undo what it did when an error occurs. Think about a chain of actions where you need
to persist records in your data store in one action and you have to call an external service in the next. What happens if there
is an error when you call the external service? You want to remove the records you previously saved. You can do it now with
the `rolled_back` macro.

```ruby
class SaveEntities
  extend LightService::Action
  expects :user

  executed do |context|
    context.user.save!
  end

  rolled_back do |context|
    context.user.destroy
  end
end
```

You need to call the `fail_with_rollback!` method to initiate a rollback for actions starting with the action where the failure
was triggered.

```ruby
class CallExternalApi
  extend LightService::Action

  executed do |context|
    api_call_result = SomeAPI.save_user(context.user)

    context.fail_with_rollback!("Error when calling external API") if api_call_result.failure?
  end
end
```

Using the `rolled_back` macro is optional for the actions in the chain. You shouldn't care about undoing non-persisted changes.

The actions are rolled back in reversed order from the point of failure starting with the action that triggered it.

See [this](spec/acceptance/rollback_spec.rb) acceptance test to learn more about this functionality.

## Localizing Messages
By default LightService provides a mechanism for easily translating your error or success messages via I18n.  You can also provide your own custom localization adapter if your application's logic is more complex than what is shown here.

```ruby
class FooAction
  extend LightService::Action

  executed do |context|
    unless service_call.success?
      context.fail!(:exceeded_api_limit)

      # The failure message used here equates to:
      # I18n.t(:exceeded_api_limit, scope: "foo_action.light_service.failures")
    end
  end
end
```

This also works with nested classes via the ActiveSupport `#underscore` method, just as ActiveRecord performs localization lookups on models placed inside a module.

```ruby
module PaymentGateway
  class CaptureFunds
    extend LightService::Action

    executed do |context|
      if api_service.failed?
        context.fail!(:funds_not_available)
      end

      # this failure message equates to:
      # I18n.t(:funds_not_available, scope: "payment_gateway/capture_funds.light_service.failures")
    end
  end
end
```

If you need to provide custom variables for interpolation during localization, pass that along in a hash.

```ruby
module PaymentGateway
  class CaptureFunds
    extend LightService::Action

    executed do |context|
      if api_service.failed?
        context.fail!(:funds_not_available, last_four: "1234")
      end

      # this failure message equates to:
      # I18n.t(:funds_not_available, last_four: "1234", scope: "payment_gateway/capture_funds.light_service.failures")

      # the translation string itself being:
      # => "Unable to process your payment for account ending in %{last_four}"
    end
  end
end
```

To provide your own custom adapter, use the configuration setting and subclass the default adapter LightService provides.

```ruby
LightService::Configuration.localization_adapter = MyLocalizer.new

# lib/my_localizer.rb
class MyLocalizer < LightService::LocalizationAdapter

  # I just want to change the default lookup path
  # => "light_service.failures.payment_gateway/capture_funds"
  def i18n_scope_from_class(action_class, type)
    "light_service.#{type.pluralize}.#{action_class.name.underscore}"
  end
end
```

To get the value of a `fail!` or `succeed!` message, simply call `#message` on the returned context.

## Orchestrator Logic in Organizers

The Organizer - Action combination works really well for simple use cases. However, as business logic gets more complex, or when LightService is used in an ETL workflow, the code that routes the different organizers becomes very complex and imperative. Let's look at a piece of code that does basic data transformations:

```ruby
class ExtractsTransformsLoadsData
  def self.run(connection)
    context = RetrievesConnectionInfo.call(connection)
    context = PullsDataFromRemoteApi.call(context)

    retrieved_items = context.retrieved_items
    if retrieved_items.empty?
      NotifiesEngineeringTeamAction.execute(context)
    end

    retrieved_items.each do |item|
      context[:item] = item
      TransformsData.call(context)
    end

    context = LoadsData.call(context)

    SendsNotifications.call(context)
  end
end
```

The `LightService::Context` is initialized with the first action, that context is passed around among organizers and actions. This code is still simpler than many out there, but it feels very imperative: it has conditionals, iterators in it. Let's see how we could make it a bit more simpler with a declarative style:

```ruby
class ExtractsTransformsLoadsData
  extend LightService::Organizer

  def self.call(connection)
    with(:connection => connection).reduce(actions)
  end

  def self.actions
    [
      RetrievesConnectionInfo,
      PullsDataFromRemoteApi,
      reduce_if(->(ctx) { ctx.retrieved_items.empty? }, [
        NotifiesEngineeringTeamAction
      ]),
      iterate(:retrieved_items, [
        TransformsData
      ]),
      LoadsData,
      SendsNotifications
    ]
  end
end
```

This code is much easier to reason about, it's less noisy and it captures the goal of LightService well: simple, declarative code that's easy to understand.

The 5 different orchestrator constructs an organizer can have:

1. `reduce_until`
2. `reduce_if`
3. `iterate`
4. `execute`
5. `with_callback`

`reduce_until` behaves like a while loop in imperative languages, it iterates until the provided predicate in the lambda evaluates to true. Take a look at [this acceptance test](spec/acceptance/organizer/reduce_until_spec.rb) to see how it's used.

`reduce_if` will reduce the included organizers and/or actions if the predicate in the lambda evaluates to true. [This acceptance test](spec/acceptance/organizer/reduce_if_spec.rb) describes this functionality.

`iterate` gives your iteration logic, the symbol you define there has to be in the context as a key. For example, to iterate over items you will use `iterate(:items)` in your steps, the context needs to have `items` as a key, otherwise it will fail. The organizer will singularize the collection name and will put the actual item into the context under that name. Remaining with the example above, each element will be accessible by the name `item` for the actions in the `iterate` steps. [This acceptance test](spec/acceptance/organizer/iterate_spec.rb) should provide you with an example.

To take advantage of another organizer or action, you might need to tweak the context a bit. Let's say you have a hash, and you need to iterate over its values in a series of action. To alter the context and have the values assigned into a variable, you need to create a new action with 1 line of code in it. That seems a lot of ceremony for a simple change. You can do that in a `execute` method like this `execute(->(ctx) { ctx[:some_values] = ctx.some_hash.values })`. [This test](spec/acceptance/organizer/execute_spec.rb) describes how you can use it.

Use `with_callback` when you want to execute actions with a deferred and controlled callback. It works similar to a Sax parser, I've used it for processing large files. The advantage of it is not having to keep large amount of data in memory. See [this acceptance test](spec/acceptance/organizer/with_callback_spec.rb) as a working example.

## ContextFactory for Faster Action Testing

As the complexity of your workflow increases, you will find yourself spending more and more time creating a context (LightService::Context it is) for your action tests. Some of this code can be reused by clever factories, but still, you are using a context that is artificial, and can be different from what the previous actions produced. This is especially true, when you use LightService in ETLs, where you start out with initial data and your actions are mutating its state.

Here is an example:

```ruby
class SomeOrganizer
  extend LightService::Organizer

  def self.call(ctx)
    with(ctx).reduce(actions)
  end

  def self.actions
    [
       ETL::ParsesPayloadAction,
       ETL::BuildsEnititiesAction,
       ETL::SetsUpMappingsAction,
       ETL::SavesEntitiesAction,
       ETL::SendsNotificationAction
    ]
  end
end
```

You should test your workflow from the outside, invoking the organizer’s `call` method and verify that the data was properly created or updated in your data store. However, sometimes you need to zoom into one action, and setting up the context to test it is tedious work. This is where `ContextFactory` can be helpful.

In order to test the third action `ETL::SetsUpMappingAction`, you have to have several entities in the context. Depending on the logic you need to write code for, this could be a lot of work. However, by using the `ContextFactory` in your spec, you could easily have a prepared context that’s ready for testing:

```ruby
require 'spec_helper'
require 'light-service/testing'

RSpec.describe ETL::SetsUpMappingsAction do
  let(:context) do
    LightService::Testing::ContextFactory
      .make_from(SomeOrganizer)
      .for(described_class)
      .with(:payload => File.read(‘spec/data/payload.json’)
  end

  it ‘works like it should’ do
    result = described_class.execute(context)
    expect(result).to be_success
  end
end
```

This context then can be passed to the action under test, freeing you up from the 20 lines of factory or fixture calls to create a context for your specs.

In case your organizer has more logic in its `call` method, you could create your own test organizer in your specs like you can see it in this [acceptance test](spec/acceptance/testing/context_factory_spec.rb#L4-L11). This is reusable in all your action tests.

## Requirements

This gem requires ruby 2.x

## Installation
Add this line to your application's Gemfile:

    gem 'light-service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install light-service

## Usage
Based on the refactoring example above, just create an organizer object that calls the
actions in order and write code for the actions. That's it.

For further examples, please visit the project's [Wiki](https://github.com/adomokos/light-service/wiki).

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Huge thanks to the [contributors](https://github.com/adomokos/light-service/graphs/contributors)!

## Release Notes
Follow the release notes in this [document](https://github.com/adomokos/light-service/blob/master/RELEASES.md).

## License
LightService is released under the [MIT License](http://www.opensource.org/licenses/MIT).
