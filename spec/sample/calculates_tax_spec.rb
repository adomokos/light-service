require 'spec_helper'
require_relative 'tax/calculates_tax'
require_relative 'tax/looks_up_tax_percentage_action'
require_relative 'tax/calculates_order_tax_action'
require_relative 'tax/provides_free_shipping_action'

describe CalculatesTax do
  let(:order) { double('order') }
  let(:context) { double('context') }

  it "calls the actions in order" do
    ::LightService::Context.stub(:make) \
                            .with(:order => order) \
                            .and_return context

    LooksUpTaxPercentageAction.stub(:execute).with(context)
    CalculatesOrderTaxAction.stub(:execute).with(context)
    ProvidesFreeShippingAction.stub(:execute).with(context)

    result = CalculatesTax.for_order(order)
    result.should eq context
  end
end
