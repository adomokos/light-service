class CalculatesTax
  def self.for_order(order)
    context = ::LightService::Context.make(:order => order)

    [
      LooksUpTaxPercentageAction,
      CalculatesOrderTaxAction,
      ProvidesFreeShippingAction
    ].each{ |action| action.execute(context) }

    context
  end
end
