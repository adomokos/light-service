class CalculatesOrderTaxAction
  include ::LightService::Action
  expects :order, :tax_percentage

  executed do |context|
    order.tax = (order.total * (tax_percentage/100)).round(2)
  end
end
