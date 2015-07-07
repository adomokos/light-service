require 'spec_helper'
require_relative 'tax/calculates_tax'
require_relative 'tax/looks_up_tax_percentage_action'
require_relative 'tax/calculates_order_tax_action'
require_relative 'tax/provides_free_shipping_action'

describe CalculatesTax do
  let(:order) { double('order') }
  let(:context) { double('context', :keys => [:user],
                         :failure? => false, :skip_all? => false) }

  it "calls the actions in order" do
    allow(LooksUpTaxPercentageAction).to receive(:execute).and_return context
    allow(CalculatesOrderTaxAction).to receive(:execute).and_return context
    allow(ProvidesFreeShippingAction).to receive(:execute).and_return context

    result = CalculatesTax.for_order(order)

    expect(result).to eq context
  end
end
