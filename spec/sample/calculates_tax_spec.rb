require 'spec_helper'
require_relative 'tax/calculates_tax'
require_relative 'tax/looks_up_tax_percentage_action'
require_relative 'tax/calculates_order_tax_action'
require_relative 'tax/provides_free_shipping_action'

describe CalculatesTax do
  let(:order) { double('order') }
  let(:context) { double('context', :keys => [:user]) }

  it "calls the actions in order" do
    allow(::LightService::Context).to receive(:make) \
                            .with(:order => order) \
                            .and_return context

    allow(LooksUpTaxPercentageAction).to receive(:execute).with(context).and_return context
    allow(CalculatesOrderTaxAction).to receive(:execute).with(context).and_return context
    allow(ProvidesFreeShippingAction).to receive(:execute).with(context).and_return context

    result = CalculatesTax.for_order(order)

    expect(result).to eq context
  end
end
