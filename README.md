![LightService](https://raw.github.com/adomokos/light-service/master/resources/light-service.png)

[![Gem Version](https://img.shields.io/gem/v/light-service.svg)](https://rubygems.org/gems/light-service)
[![Build Status](https://secure.travis-ci.org/adomokos/light-service.png)](http://travis-ci.org/adomokos/light-service)
[![Code Climate](https://codeclimate.com/github/adomokos/light-service.png)](https://codeclimate.com/github/adomokos/light-service)

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
Also, imagine what would it take to test this beast.
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
  LooksUpTaxPercentageAction,
  CalculatesOrderTaxAction,
  ChecksFreeShippingAction
)
```

This block of code should tell you the "story" of what's going on in this workflow.
With the help of LightService you can write code this way. First you need an organizer object that sets up the actions in order
and executes them one-by-one. Then you need to create the actions which will only have one method and will do only one thing.

This is how the organizer and actions interact with eachother:

![LightService](https://raw.github.com/adomokos/light-service/master/resources/organizer_and_actions.png)

```ruby
class CalculatesTax
  extend LightService::Organizer

  def self.for_order(order)
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

  executed do |context|
    order.tax = (order.total * (tax_percentage/100)).round(2)
  end

end

class ProvidesFreeShippingAction
  extend LightService::Action
  expects :order

  executed do |context|
    if order.total_with_tax > 200
      order.provide_free_shipping!
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


## Table of Content
* [Stopping the Series of Actions](#stopping-the-series-of-actions)
    * [Failing the Context](#failing-the-context)
    * [Skipping the Rest of the Actions](#skipping-the-rest-of-the-actions)
* [Benchmarking Actions with Around Advice](#benchmarking-actions-with-around-advice)
* [Key Aliases](#key-aliases)
* [Logging](#logging)
* [Error Codes](#error-codes)
* [Action Rollback](#action-rollback)
* [Localizing Messages](#localizing-messages)

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

Here is an example:
```ruby
class SubmitsOrderAction
  extend LightService::Action
  expects :order, :mailer

  executed do |context|
    unless context.order.submit_order_succeful?
      context.fail!("Failed to submit the order")
      next context
    end

    context.mailer.send_order_notification!
  end
end
```
![LightService](https://raw.github.com/adomokos/light-service/master/resources/fail_actions.png)

In the example above the organizer called 4 actions. The first 2 actions got executed successfully. The 3rd had a failure, that pushed the context into a failure state and the 4th action was skipped.

### Skipping the rest of the actions
You can skip the rest of the actions by calling `context.skip_all!`. This behaves very similarly to the above-mentioned `fail!` mechanism, except this will not push the context into a failure state.
A good use case for this is executing the first couple of action and based on a check you might not need to execute the rest.
Here is an example of how you do it:
```ruby
class ChecksOrderStatusAction
  extend LightService::Action
  expects :order

  executed do |context|
    if context.order.send_notification?
      context.skip_all!("Everything is good, no need to execute the rest of the actions")
    end
  end
end
```
![LightService](https://raw.github.com/adomokos/light-service/master/resources/skip_actions.png)

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

  def self.for_order(order)
    with(:order => order).around_each(LogDuration).reduce(
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
      )
  end
end
```

Any object passed into `around_each` must respond to #call with two arguments: the action name and the context it will execute with. It is also passed a block, where LightService's action execution will be done in, so the result must be returned. While this is a little work, it also gives you before and after state access to the data for any auditing and/or checks you may need to accomplish.


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

Take a look at [this spec](https://github.com/adomokos/light-service/blob/master/spec/action_expects_and_promises_spec.rb) to see the refactoring in action.

## Key Aliases
The `aliases` macro sets up pairs of keys and aliases in an organizer. Actions can access the context using the aliases.

This allows you to put together existing actions from different sources and have them work together without having to modify their code. Aliases will work with or without action `expects`.

Say for example you have actions `AnAction` and `AnotherAction` that you've used in previous projects.  `AnAction` provides `:my_key` but `AnotherAction` needs to use that value but expects `:key_alias`.  You can use them together in an organizer like so:

```ruby
class AnOrganizer
  extend LightService::Organizer

  aliases my_key: :key_alias

  def self.for_order(order)
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

See [this](https://github.com/adomokos/light-service/blob/master/spec/acceptance/rollback_spec.rb) acceptance test to learn more about this functionality.

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
