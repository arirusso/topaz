require "helper"

class Topaz::ClockTest < Minitest::Test

  context "Clock" do

    setup do
      @counter = 0
      @count_to = 5
      @tempo = Topaz::Clock.new(120) { @counter += 1 }
    end

    context "#interval=" do

      should "change interval" do
        assert_equal(4, @tempo.interval)
        @tempo.interval = 8
        assert_equal(8, @tempo.interval)
      end

    end

    context "Event" do

      context "#tick" do

        should "change tick" do
          @is_running = false
          @tempo.event.tick { @is_running = true }
          refute @is_running

          @tempo.start(:background => true)
          loop until @tempo.running?
          loop until @is_running

        end

      end

    end

    context "Trigger" do

      context "#stop" do

        setup do
          @tempo.trigger.stop { @counter.eql?(@count_to) }
        end

        should "stop" do
          @tempo.start
          assert_equal(@count_to, @counter)
        end

      end

    end



  end
end
