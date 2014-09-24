require "helper"

class Topaz::TempoCalculatorTest < Test::Unit::TestCase

  context "TempoCalculator" do

    setup do
      @calc = Topaz::TempoCalculator.new
    end

    context "#calculate" do

      should "wait for two timestamps to start calculation" do
        @calc.timestamps << 1
        assert_nil @calc.calculate
        @calc.timestamps << 2
        @calc.timestamps << 3
        assert_not_nil @calc.calculate
      end

      should "limit timestamps do within the threshold" do
        10.times { |i| @calc.timestamps << i }
        @calc.calculate
        assert_equal Topaz::TempoCalculator::THRESHOLD, @calc.timestamps.count
      end

      should "express tempo" do
        5.times { |i| @calc.timestamps << Time.now.to_f; sleep(1 / 24.to_f) }
        result = @calc.calculate
        assert_not_nil result
        assert (59..61).include?(result)
      end

    end

  end

end

