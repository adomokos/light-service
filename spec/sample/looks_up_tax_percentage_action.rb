require 'spec_helper'
require_relative 'tax/looks_up_tax_percentage_action'

class TaxRange; end

describe LooksUpTaxPercentageAction do
  let(:region) { double('region') }
  let(:order) do
    order = double('order')
    order.stub(:region => region)
    order.stub(:total => 200)
    order
  end
  let(:context) do
    ::LightService::Context.make(:order => order)
  end
  let(:tax_percentage) { double('tax_percentage') }
  let(:tax_ranges) { double('tax_ranges') }

  context "when the tax_ranges were not found" do
    it "sets the context to failure" do
      TaxRange.stub(:for_region).with(region).and_return nil
      LooksUpTaxPercentageAction.execute(context)

      context.should be_failure
      context.message.should eq "The tax ranges were not found"
    end
  end

  context "when the tax_percentage is not found" do
    it "sets the context to failure" do
      TaxRange.stub(:for_region).with(region).and_return tax_ranges
      tax_ranges.stub(:for_total => nil)

      LooksUpTaxPercentageAction.execute(context)

      context.should be_failure
      context.message.should eq "The tax percentage was not found"
    end
  end

  context "when the tax_percentage is found" do
    it "sets the tax_percentage in context" do
      TaxRange.stub(:for_region).with(region).and_return tax_ranges
      tax_ranges.stub(:for_total => 25)

      LooksUpTaxPercentageAction.execute(context)

      context.should be_success
      context.fetch(:tax_percentage).should eq 25
    end
  end
end
