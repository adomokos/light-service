require 'spec_helper'

describe ":expects" do
  describe ":validates" do
    it 'validates presence' do
      result = TestDoubles::AddsNumbersWithValidations.execute(:first_number => 1, :second_number => 2)
      expect(result.total).to eq 3
    end

    it 'raises on validation error' do
      expect do
        TestDoubles::AddsNumbersWithValidations.execute(:first_number => nil, :second_number => nil)
      end.to raise_error(::LightService::InvalidKeysError)
    end
  end
end