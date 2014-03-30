class CalculatesTax
  include LightService::Organizer

  def self.for_order(order)
    with(:order => order).reduce(
        LooksUpTaxPercentageAction,
        CalculatesOrderTaxAction,
        ProvidesFreeShippingAction
    )
  end
end
