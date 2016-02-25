class LooksUpTaxPercentageAction
  extend LightService::Action
  expects :order
  promises :tax_percentage

  executed do |ctx|
    tax_ranges = TaxRange.for_region(ctx.order.region)
    ctx.tax_percentage = 0

    next ctx if object_is_nil?(tax_ranges, ctx, 'The tax ranges were not found')

    ctx.tax_percentage = tax_ranges.for_total(ctx.order.total)

    error_message = 'The tax percentage was not found'
    next ctx if object_is_nil?(ctx.tax_percentage, ctx, error_message)
  end

  def self.object_is_nil?(object, ctx, message)
    if object.nil?
      ctx.fail!(message)
      return true
    end

    false
  end
  private_class_method :object_is_nil?
end
