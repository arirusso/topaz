require "helper"

class Topaz::MIDIClockOutputTest < Test::Unit::TestCase

  context "MIDIClockOutput" do

    setup do
      @output = Object.new
      @clock = Topaz::MIDIClockOutput.new(:device => @output)
    end

    context "#do_start" do
      
      should "emit start message" do
        @output.expects(:puts).once.with(250)
        result = @clock.do_start
        assert result
        @output.unstub(:puts)
      end

    end

    context "#do_stop" do

      should "emit stop message" do
        @output.expects(:puts).once.with(252)
        result = @clock.do_stop
        assert result
        @output.unstub(:puts)
      end

    end

    context "#do_clock" do

      should "emit clock message" do
        @output.expects(:puts).once.with(248)
        result = @clock.do_clock
        assert result
        @output.unstub(:puts)
      end

    end

  end

end



