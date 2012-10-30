# LightService

What do you think of this code?

```ruby
class TaxController < ApplicationContoller
  def update
    @order = Order.find(243)
    tax_ranges = TaxRanges.for_region(my_region)

    if tax_ranges.nil?
      render 'tax_summary', :notice => 'The tax ranges were not found'
    end

    tax_percentage = tax_ranges.for_total(@order.total)

    if tax_percentage.nil?
      render 'tax_summary', :notice => 'The tax percentage  was not found'
    end

    @order.tax = @order.total * tax_percentage

    if @order.tax > 25
      # Provide free shipping
      @order.provide_free_shipping!
    end

    render 'tax_summary'
  end
end
```

This controller violates SRP all over. You could move the finder of tax_ranges and tax_percentage 
into the tax model, but then you'll make your model logic heavy.

This controller does 4 things in order:
* Finds the order
* Looks up the tax percentage based on order total
* Calculates the order tax
* Provides free shipping if the tax is greater than $25

The order of this tasks matters: you can't calculate the order tax without the percentage.
Wouldn't it be nice to see this instead?

```ruby
[
  LooksUpTaxPercentage
  CalculatesOrderTax
  ProvidesFreeShipping
]
```

With the help of LightService you can write code this way. First you need an organizer object that sets up the actions in order
and executes them one-by-one. Then you need to create the actions which will only have one method and will do only one thing.

```ruby
class CalculatesTax
  def self.for_order(order)
    context = ::LightService::Context.make(:order => order)

    [
      LooksUpTaxPercentageAction,
      CalculatesOrderTax,
      ProvidesFreeShipping
    ].each{ |action| action.execute(context) }

    context
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

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
