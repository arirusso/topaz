require "helper"

class Topaz::TempoSourceTest < Test::Unit::TestCase

  context "TempoSource" do

    context ".new" do

      should "construct a timer" do
        result = Topaz::TempoSource.new(120)
        assert_not_nil result
        assert_equal Topaz::Timer, result.class
      end

      should "construct a midi input clock" do
        result = Topaz::TempoSource.new($test_device[:input])
        assert_not_nil result
        assert_equal Topaz::MIDIClockInput, result.class
      end

      should "throw an exception" do
        assert_raise RuntimeError do
          Topaz::TempoSource.new("something")
        end
      end

    end

  end

end


