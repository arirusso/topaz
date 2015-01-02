require "helper"

class Topaz::TempoSourceTest < Minitest::Test

  context "TempoSource" do

    context ".new" do

      should "construct a timer" do
        result = Topaz::TempoSource.new(120)
        refute_nil result
        assert_equal Topaz::Timer, result.class
      end

      should "construct a midi input clock" do
        result = Topaz::TempoSource.new($test_device[:input])
        refute_nil result
        assert_equal Topaz::MIDIClockInput, result.class
      end

      should "throw an exception" do
        assert_raises RuntimeError do
          Topaz::TempoSource.new("something")
        end
      end

    end

  end

end
