class ProvidesFreeShippingAction
  extend LightService::Action
  expects :order

  executed do |context|
    order = context.order

    order.provide_free_shipping! if order.total_with_tax > 200
  end
end
