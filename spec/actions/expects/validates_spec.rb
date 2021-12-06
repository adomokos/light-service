require 'spec_helper'

describe ":expects" do
  describe ":validates" do
    it 'validates presence' do
      result = TestDoubles::AddsNumbersWithPresenceValidations.execute(:first_number => 1, :second_number => 2)
      expect(result.total).to eq 3
    end

    it 'raises on validation error' do
      expect do
        TestDoubles::AddsNumbersWithPresenceValidations.execute(:first_number => nil, :second_number => 2)
      end.to raise_error(::LightService::InvalidKeysError)
    end

    it 'validates :class_name option' do
      expect do
        TestDoubles::AddsNumbersWithClassNameValidations.execute(:first_number => 1.0, :second_number => 2)
      end.to raise_error(::LightService::InvalidKeysError)
    end

    it 'validates :class option' do
      expect do
        TestDoubles::AddsNumbersWithClassValidations.execute(:first_number => 1.0, :second_number => 2)
      end.not_to raise_error(::LightService::InvalidKeysError)
      expect do
        TestDoubles::AddsNumbersWithClassValidations.execute(:first_number => :foo, :second_number => 2)
      end.to raise_error(::LightService::InvalidKeysError)
    end
  end
end