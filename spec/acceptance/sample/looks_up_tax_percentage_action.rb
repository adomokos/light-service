class LooksUpTaxPercentageAction
  include LightService::Action

  executed do |context|
    order = context.fetch(:order)
    tax_ranges = TaxRange.for_region(order.region)

    if tax_ranges.nil?
      context.set_failure!('The tax ranges were not found')
      next context
    end

    order = context.fetch(:order)
    tax_percentage = tax_ranges.for_total(order.total)

    if tax_percentage.nil?
      context.set_failure!('The tax percentage was not found')
      next context
    end

    context[:tax_percentage] = tax_percentage
  end

end
