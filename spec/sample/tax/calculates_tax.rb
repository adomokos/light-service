class CalculatesTax
  extend LightService::Organizer

  def self.for_order(order)
    with(:order => order).reduce(
      LooksUpTaxPercentageAction,
      CalculatesOrderTaxAction,
      ProvidesFreeShippingAction
    )
  end
end
