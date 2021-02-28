require 'spec_helper'

describe LightService::Refinements::Array do
  let(:an_array) { ['an array'] }

  context 'when our refinements are in place' do
    context '.wrap' do
      context 'when nil is passed as argument' do
        it 'returns an empty array' do
          expect(Array.wrap(nil)).to eq([])
        end
      end

      context 'when an array is passed as argument' do
        it 'returns the same array w/o creating a new object' do
          expect(Array.wrap(an_array)).to be(an_array)
        end
      end

      context 'when an object which is not an array is passed as argument' do
        it 'returns the object wrapped into an array' do
          expect(Array.wrap('test')).to eq(['test'])
        end
      end
    end
  end
end
