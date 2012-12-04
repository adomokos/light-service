[[https://raw.github.com/adomokos/light_service/master/light_service.png]]

# LightService

What do you think of this code?

```ruby
class TaxController < ApplicationContoller
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
Also, imagine what it takes to test this beast.
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

This should tell you the "story" of what's going on in this workflow.
With the help of LightService you can write code this way. First you need an organizer object that sets up the actions in order
and executes them one-by-one. Then you need to create the actions which will only have one method and will do only one thing.

```ruby
class CalculatesTax
  def self.for_order(order)
    context = LightService::Context.make(:order => order)

    [
      LooksUpTaxPercentageAction,
      CalculatesOrderTaxAction,
      ProvidesFreeShippingAction
    ].each{ |action| action.execute(context) }

    context
  end
end

class LooksUpTaxPercentageAction
  include LightService::Action

  executed do |context|
    order = context.fetch(:order)
    tax_ranges = TaxRange.for_region(order.region)

    if tax_ranges.nil?
      context.set_failure!("The tax ranges were not found")
      next context
    end

    order = context.fetch(:order)
    tax_percentage = tax_ranges.for_total(order.total)

    if tax_percentage.nil?
      context.set_failure!("The tax percentage was not found")
      next context
    end

    context[:tax_percentage] = tax_percentage
  end
end

class CalculatesOrderTaxAction
  include LightService::Action

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

## Installation

Add this line to your application's Gemfile:

    gem 'light_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install light_service

## Usage

Based on the refactoring example above, just create an organizer object that calls the 
actions in order and write code for the actions. That's it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
