class ProvidesFreeShippingAction
  include LightService::Action

  executed do |context|
    order = context.fetch(:order)

    if order.total_with_tax > 200
      order.provide_free_shipping!
    end
  end

end
