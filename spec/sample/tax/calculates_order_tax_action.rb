class CalculatesOrderTaxAction
  extend ::LightService::Action
  expects :order, :tax_percentage

  executed do |ctx|
    order_total = (ctx.order.total * (ctx.tax_percentage / 100))
    ctx.order.tax = order_total.round(2)
  end
end
