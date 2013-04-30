require 'spec_helper'
require_relative 'tax/provides_free_shipping_action'

describe ProvidesFreeShippingAction do
  let(:order) { double('order') }
  let(:context) do
    data = { :order => order }
    ::LightService::Context.make(data)
  end

  context "when the order total with tax is > 200" do
    specify "order gets free shipping" do
      order.stub(:total_with_tax => 201)
      order.should_receive(:provide_free_shipping!)

      ProvidesFreeShippingAction.execute(context)
    end
  end

  context "when the order total with tax is <= 200" do
    specify "order gets free shipping" do
      order.stub(:total_with_tax => 200)
      order.should_not_receive(:provide_free_shipping!)

      ProvidesFreeShippingAction.execute(context)
    end
  end

end
