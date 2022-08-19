# frozen_string_literal: true

require 'unit/helper'

describe Topaz::TempoSource do
  describe '#initialize' do
    context 'when a numeric tempo is given' do
      it 'constructs a timer' do
        result = Topaz::TempoSource.new(120)
        expect(result).to_not be_nil
        expect(result).to be_a(Topaz::Timer)
      end
    end

    context 'when something invalid is given' do
      it 'throws an exception' do
        expect { Topaz::TempoSource.new('not an input') }.to raise_error(RuntimeError)
      end
    end
  end
end
