# frozen_string_literal: true

require 'unit/helper'

describe Topaz::TempoCalculator do
  let(:calc) { Topaz::TempoCalculator.new }

  describe '#calculate' do
    it 'waits for two timestamps to start calculation' do
      calc.timestamps << 1
      expect(calc.calculate).to be_nil
      calc.timestamps << 2
      calc.timestamps << 3
      expect(calc.calculate).to_not be_nil
    end

    it 'limits timestamps to within the threshold' do
      10.times { |i| calc.timestamps << i }
      calc.calculate
      expect(calc.timestamps.count).to eq(Topaz::TempoCalculator::THRESHOLD)
    end

    it 'expresses tempo' do
      5.times { |i| calc.timestamps << i * (1.0 / 24.0) }
      result = calc.calculate
      expect(result).to_not be_nil
      expect(result).to eq(60)
    end
  end
end
