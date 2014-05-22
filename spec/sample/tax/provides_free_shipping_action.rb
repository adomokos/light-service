class ProvidesFreeShippingAction
  include LightService::Action
  expects :order

  executed do |context|
    order = context.order
    if order.total_with_tax > 200
      order.provide_free_shipping!
    end
  end

end
