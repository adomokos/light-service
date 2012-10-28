require 'spec_helper'

describe "Calling a chain of 2 actions" do
  # The first action
  class FindsCartAction < ::LightService::ActionBase
    action_execute do |context|
      cart = OpenStruct.new(name: "cart",
                               number_of_items: 2,
                               total: 100)
      context[:cart] = cart
    end
  end

  # The second action
  class CalculatesTaxAction < ::LightService::ActionBase
    action_execute do |context|
      cart = context.fetch(:cart)
      context[:tax] = (cart.total * 0.07).round(2)
    end
  end

  # The organizer, that calls the actions
  class Checkout
    def self.with_cart
      context = ::LightService::Context.new

      [ ::FindsCartAction,
        ::CalculatesTaxAction].each { |action| action.execute(context) }

      context
    end
  end

  it "calls them in order" do
    result = Checkout.with_cart

    result.context_hash.keys.should eq [:cart, :tax]
    result[:tax].should eq 7.0
  end
end
