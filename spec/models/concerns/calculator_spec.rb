require 'rails_helper'

describe Calculator do
  class FakeModel
    include Calculator
  end

  let(:model) { FakeModel.new }

  describe '#average' do
    context 'when empty arrow' do
      it 'returns nil' do
        expect(model.average([])).to be_nil
      end
    end

    context 'when numbers in array' do
      it 'calculates the average of the numbers' do
        expect(model.average([1, 2, 3])).to eq(2)
      end

      it 'calculates decimal result when needed' do
        expect(model.average([1, 2, 3, 4])).to eq(2.5)
      end
    end
  end
end