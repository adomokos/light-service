![LightService](https://raw.github.com/adomokos/light-service/master/resources/light-service.png)

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
[
  LooksUpTaxPercentage,
  CalculatesOrderTax,
  ChecksFreeShipping
]
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
    with(order: order).reduce \
      [
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
      ]
  end
end

class LooksUpTaxPercentageAction
  include LightService::Action

  executed do |context|
    order = context.fetch(:order)
    tax_ranges = TaxRange.for_region(order.region)

    next context if object_is_nil?(tax_ranges, context, 'The tax ranges were not found')

    order = context.fetch(:order)
    tax_percentage = tax_ranges.for_total(order.total)

    next context if object_is_nil?(tax_percentage, context, 'The tax percentage was not found')

    context[:tax_percentage] = tax_percentage
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

  executed do |context|
    order = context.fetch(:order)
    tax_percentage = context.fetch(:tax_percentage)

    order.tax = (order.total * (tax_percentage/100)).round(2)
  end

end

class ProvidesFreeShippingAction
  include LightService::Action

  executed do |context|
    order = context.fetch(:order)

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

### 0.2.0
* [Renaming](https://github.com/adomokos/light-service/commit/8d40ff7d393a157a8a558f9e4e021b8731550834) the `set_success!` and `set_failure!` methods to `succeed!` and `fail!`.
* [Throwing](https://github.com/adomokos/light-service/commit/5ef315b8aeeafc99e38676adad3c11df5d93b0e3) an ArgumentError if the `make` method's argument is not Hash or LightService::Context.

## License

LightService is released under the [MIT License](http://www.opensource.org/licenses/MIT).
