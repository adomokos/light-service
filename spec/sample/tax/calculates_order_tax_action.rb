class CalculatesOrderTaxAction
  include ::LightService::Action
  expects :order, :tax_percentage

  executed do |context|
    context.order.tax = (context.order.total * (context.tax_percentage/100)).round(2)
  end
end
