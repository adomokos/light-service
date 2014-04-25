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
    tax_ranges = TaxRange.for_region(self.order.region)
    self.tax_percentage = 0

    next context if object_is_nil?(tax_ranges, context, 'The tax ranges were not found')

    self.tax_percentage = tax_ranges.for_total(self.order.total)

    next context if object_is_nil?(self.tax_percentage, context, 'The tax percentage was not found')
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
`expects` describes what keys it needs in order to execute and `promises` makes sure the keys are in the context after the
action is reduced. If either of them are violated, a custom exception is thrown.

When you look at action like this:
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

The `expects` macro does a bit more for you: it pulls the value with the expected key from the context and 
makes it available to you through a reader. You can refactor the action like this:

```ruby
class FooAction
  include LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    bar = self.baz + 2
    context[:bar] = bar
  end
end
```

The `promises` macro will not only check if the context has the keys you promised, it also sets it for you in the context if
you use the accessor with the same name you used with the promise. The code above can be further simplified:

```ruby
class FooAction
  include LightService::Action
  expects :baz
  promises :bar

  executed do |context|
    self.bar = self.baz + 2
  end
end
```

Take a look at this spec to see the refactoring in action.

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
### 0.2.2
* Adding the gem version icon to README
* Actions can be invoked now [without arguments](https://github.com/adomokos/light-service/commit/244d5f03b9dbf61c97c1fdb865e6587f9aea177d), this makes it super easy to play with an action in the command line

### 0.2.1
* [Improving](https://github.com/adomokos/light-service/commit/fc7043241396b4a2556e9664c13c6929f8330025) deprecation warning for the renamed methods
* Making the message an optional argument for `succeed!` and `fail!` methods

### 0.2.0
* [Renaming](https://github.com/adomokos/light-service/commit/8d40ff7d393a157a8a558f9e4e021b8731550834) the `set_success!` and `set_failure!` methods to `succeed!` and `fail!`
* [Throwing](https://github.com/adomokos/light-service/commit/5ef315b8aeeafc99e38676adad3c11df5d93b0e3) an ArgumentError if the `make` method's argument is not Hash or LightService::Context

## License

LightService is released under the [MIT License](http://www.opensource.org/licenses/MIT).
