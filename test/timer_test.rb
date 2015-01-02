require "helper"

class Topaz::TimerTest < Minitest::Test

  context "Timer" do

    setup do
      @timer = Topaz::Timer.new(120)
    end

    context "#dispatch" do

      setup do
        @event = Object.new
        @timer = Topaz::Timer.new(120, :event => @event)
        @timer.send(:initialize_running_state)
        @event.expects(:do_clock).once.returns(true)
        @event.expects(:do_tick).once.returns(true)
      end

      teardown do
        @event.unstub(:do_clock)
        @event.unstub(:do_tick)
      end

      should "fire MIDI clock/tick events" do
        @timer.send(:dispatch)
      end

    end

    context "#start" do

      should "start running" do
        assert_nil @timer.phase
        @timer.start(:background => true)
        loop until @timer.running?

        assert @timer.running?
        refute_nil @timer.phase
        refute_equal 0.0, @timer.phase
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
        refute_nil @timer.phase
        refute_equal 0.0, @timer.phase
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
