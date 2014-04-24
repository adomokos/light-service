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
