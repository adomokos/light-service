require 'spec_helper'
require_relative 'tax/provides_free_shipping_action'

describe ProvidesFreeShippingAction do
  let(:order) { double('order') }
  let(:ctx) { { :order => order } }

  context "when the order total with tax is > 200" do
    specify "order gets free shipping" do
      allow(order).to receive_messages(:total_with_tax => 201)
      expect(order).to receive(:provide_free_shipping!)

      ProvidesFreeShippingAction.execute(ctx)
    end
  end

  context "when the order total with tax is <= 200" do
    specify "order gets free shipping" do
      allow(order).to receive_messages(:total_with_tax => 200)
      expect(order).not_to receive(:provide_free_shipping!)

      ProvidesFreeShippingAction.execute(ctx)
    end
  end
end
