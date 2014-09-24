require "helper"

class InternalTempoTest < Test::Unit::TestCase

  include Topaz
  include TestHelper
  
  def test_stop_when
    i = 0
    count_to = 5
    
    tempo = Tempo.new(120) { i += 1 }
    tempo.trigger.stop { i.eql?(count_to) }
    tempo.start
    
    assert_equal(count_to, i)
  end
  
  def test_change_on_tick
    i = 0
    count_to = 5
    
    tempo = Tempo.new(120) { i += 1 }
    tempo.trigger.stop { i == count_to }
    tempo.start
    
    assert_equal(count_to, i)
    
    i = 0
    count_to = 1000
    
    tempo.event.tick { i += 100 }
    tempo.trigger.stop { i == count_to }
    tempo.start
    
    assert_equal(count_to, i)

    
  end

  def test_internal_interval
    tempo = Tempo.new(120)
    
    assert_equal(4, tempo.interval)

    tempo.interval = 8
    
    assert_equal(8, tempo.interval)
  end

end
