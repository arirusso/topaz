require "helper"

class Topaz::MIDIClockInputTest < Minitest::Test

  context "MIDIClockInput" do

    setup do
      @input = Object.new
      @event = Object.new
      @clock = Topaz::MIDIClockInput.new(@input, :event => @event)
    end

    context "#thru" do

      should "fire clock event" do
        @event.expects(:do_clock).once
        assert @clock.send(:thru)
      end

    end

    context "#tick" do

      should "fire tick event" do
        @event.expects(:do_tick).once
        assert @clock.send(:tick)
      end

    end

    context "#tick?" do

      should "tick when counter has reached tick threshold" do
        assert_equal 4, @clock.interval
        23.times do
          refute @clock.send(:tick?)
          @clock.send(:advance)
        end
        assert @clock.send(:tick?)
        @clock.send(:advance)
      end

    end

  end

end
