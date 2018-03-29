require 'spec_helper'
require_relative 'tax/calculates_tax'
require_relative 'tax/looks_up_tax_percentage_action'
require_relative 'tax/calculates_order_tax_action'
require_relative 'tax/provides_free_shipping_action'

describe CalculatesTax do
  let(:order) { double('order') }
  let(:ctx) { LightService::Context.make(:user => nil) }

  it "calls the actions in order" do
    allow(LightService::Context).to receive(:make)
      .with(:order => order)
      .and_return(ctx)

    allow(LooksUpTaxPercentageAction).to receive(:execute)
      .with(ctx)
      .and_return(ctx)
    allow(CalculatesOrderTaxAction).to receive(:execute)
      .with(ctx)
      .and_return(ctx)
    allow(ProvidesFreeShippingAction).to receive(:execute)
      .with(ctx)
      .and_return(ctx)

    result = CalculatesTax.call(order)

    expect(result).to eq(ctx)
  end
end
