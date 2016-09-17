class CalculatesTax
  extend LightService::Organizer

  def self.call(order)
    with(:order => order).reduce(
      LooksUpTaxPercentageAction,
      CalculatesOrderTaxAction,
      ProvidesFreeShippingAction
    )
  end
end
