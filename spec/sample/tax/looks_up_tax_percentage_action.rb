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
