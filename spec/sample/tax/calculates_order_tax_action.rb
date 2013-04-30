class CalculatesOrderTaxAction
  include ::LightService::Action

  executed do |context|
    order = context.fetch(:order)
    tax_percentage = context.fetch(:tax_percentage)

    order.tax = (order.total * (tax_percentage/100)).round(2)
  end

end
