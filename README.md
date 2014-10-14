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
  include LightService::Organizer

  def self.for_order(order)
    with(:order => order).reduce(
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
      )
  end
end

class LooksUpTaxPercentageAction
  include LightService::Action
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
  include ::LightService::Action
  expects :order, :tax_percentage

  executed do |context|
    order.tax = (order.total * (tax_percentage/100)).round(2)
  end

end

class ProvidesFreeShippingAction
  include LightService::Action
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

## Expects and Promises
Let me introduce to you the `expects` and `promises` macros. Think of these as a rule set of inputs/outputs for the action.
`expects` describes what keys it needs to execute and `promises` makes sure the keys are in the context after the
action is reduced. If either of them are violated, a custom exception is thrown.

This is how it's used:
```ruby
class FooAction
  include LightService::Action
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
  include LightService::Action
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
  include LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    context.bar = context.baz + 2
  end
end
```

Take a look at [this spec](spec/action_expects_and_promises_spec.rb) to see the refactoring in action.

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
  include LightService::Action

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
  include LightService::Action

  executed do |context|
    unless (service_call.success?)
      context.fail!("Service call failed", 1001)
    end

    # Do something else

    unless (entity.save)
      context.fail!("Saving the entity failed", 2001)
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
  include LightService::Action
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
  include LightService::Action

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
  include LightService::Action

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
    include LightService::Action

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

To provide your own custom localizer, use the configuration setting and subclass the default localizer LightService provides.

```ruby
LightService::Configuration.localizer = MyLocalizer.new

# lib/my_localizer.rb
class MyLocalizer < LightService::Localizer
  
  # I just want to change the default lookup path
  # => "light_service.failures.payment_gateway/capture_funds"
  def i18n_scope_from_class(action_class, type)
    "light_service.#{type.pluralize}.#{action_class.name.underscore}"
  end
end
```

## Requirements

This gem requires ruby 1.9.x

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
