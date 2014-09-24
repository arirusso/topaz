require "helper"

class Topaz::ClockTest < Test::Unit::TestCase

  context "Clock" do

    setup do
      @counter = 0
      @count_to = 5
      @tempo = Topaz::Clock.new(120) { @counter += 1 }
    end

    context "#stop" do

      setup do
        @tempo.trigger.stop { @counter.eql?(@count_to) }
      end

      should "stop" do
        @tempo.start

        assert_equal(@count_to, @counter)
      end
    end

    context "#tick" do

      should "change tick" do
        @tempo.trigger.stop { @counter == @count_to }
        @tempo.start

        assert_equal(@count_to, @counter)

        @counter = 0
        @count_to = 1000

        @tempo.event.tick { @counter += 100 }
        @tempo.trigger.stop { @counter == @count_to }
        @tempo.start

        assert_equal(@count_to, @counter)
      end

    end

    context "#interval=" do

      should "change interval" do
        assert_equal(4, @tempo.interval)
        @tempo.interval = 8
        assert_equal(8, @tempo.interval)
      end

    end

  end
end

