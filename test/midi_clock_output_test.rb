require "helper"

class Topaz::MIDIClockOutputTest < Minitest::Test

  context "MIDIClockOutput" do

    setup do
      @output = Object.new
      @clock = Topaz::MIDIClockOutput.new(:device => @output)
    end

    context "#do_start" do

      setup do
        @output.expects(:puts).once.with(250)
      end

      teardown do
        @output.unstub(:puts)
      end

      should "emit start message" do
        result = @clock.do_start
        assert result
      end

    end

    context "#do_stop" do

      setup do
        @output.expects(:puts).once.with(252)
      end

      teardown do
        @output.unstub(:puts)
      end

      should "emit stop message" do
        result = @clock.do_stop
        assert result
      end

    end

    context "#do_clock" do

      setup do
        @output.expects(:puts).once.with(248)
      end

      teardown do
        @output.unstub(:puts)
      end

      should "emit clock message" do
        result = @clock.do_clock
        assert result
      end

    end

  end

end
