require 'spec_helper'
require_relative 'tax/looks_up_tax_percentage_action'

class TaxRange
  extend LightService::Action
end

describe LooksUpTaxPercentageAction do
  let(:region) { double('region') }
  let(:order) do
    order = double('order')
    allow(order).to receive_messages(:region => region)
    allow(order).to receive_messages(:total => 200)
    order
  end
  let(:context) do
    ::LightService::Context.make(:order => order)
  end
  let(:tax_percentage) { double('tax_percentage') }
  let(:tax_ranges) { double('tax_ranges') }

  context "when the tax_ranges were not found" do
    it "sets the context to failure" do
      allow(TaxRange).to receive(:for_region).with(region).and_return nil
      LooksUpTaxPercentageAction.execute(context)

      expect(context).to be_failure
      expect(context.message).to eq "The tax ranges were not found"
    end
  end

  context "when the tax_percentage is not found" do
    it "sets the context to failure" do
      allow(TaxRange).to receive(:for_region).with(region).and_return tax_ranges
      allow(tax_ranges).to receive_messages(:for_total => nil)

      LooksUpTaxPercentageAction.execute(context)

      expect(context).to be_failure
      expect(context.message).to eq "The tax percentage was not found"
    end
  end

  context "when the tax_percentage is found" do
    it "sets the tax_percentage in context" do
      allow(TaxRange).to receive(:for_region).with(region).and_return tax_ranges
      allow(tax_ranges).to receive_messages(:for_total => 25)

      LooksUpTaxPercentageAction.execute(context)

      expect(context).to be_success
      expect(context.fetch(:tax_percentage)).to eq 25
    end
  end
end
