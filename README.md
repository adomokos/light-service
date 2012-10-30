# LightService

What do you think of this code?

```ruby
class TaxController
  def update
    @order = Order.find(243)
    tax_ranges = TaxRanges.for_region(my_region)

    if tax_ranges.nil?
      raise ('The tax ranges were not found')
    end

    tax_percentage = tax_ranges.for_total(@order.total)

    if tax_percentage.nil?
      raise('The tax percentage was not found')
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
