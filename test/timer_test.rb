require "helper"

class Topaz::TimerTest < Test::Unit::TestCase

  context "Timer" do

    setup do
      @timer = Topaz::Timer.new(120)
    end

    context "#start" do

      should "start running" do
        assert_nil @timer.phase
        @timer.start(:background => true)
        loop until @timer.running?

        assert @timer.running?
        assert_not_nil @timer.phase
        assert_not_equal 0.0, @timer.phase
      end

    end

    context "#stop" do

      setup do
        assert_nil @timer.phase
        @timer.start(:background => true)
        loop until @timer.running?

        assert @timer.running?
      end

      should "stop running" do
        assert_not_nil @timer.phase
        assert_not_equal 0.0, @timer.phase
        @timer.stop
        refute @timer.running?
      end

    end
    
    context "#interval=" do

      should "change interval" do
        assert_equal(4, @timer.interval)
        @timer.interval = 8
        assert_equal(8, @timer.interval)
      end

    end

  end

end
