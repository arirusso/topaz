#!/usr/bin/env ruby

require 'helper'

class InternalTempoTest < Test::Unit::TestCase

  include Topaz
  include TestHelper
  
  def test_stop_when
    i = 0
    count_to = 5
    
    tempo = Tempo.new(120) { i += 1 }
    tempo.stop_when { i.eql?(count_to) }
    tempo.start
    
    assert_equal(count_to, i)
  end
  
  def test_change_on_click
    i = 0
    count_to = 5
    
    tempo = Tempo.new(120) { i += 1 }
    tempo.stop_when { i.eql?(count_to) }
    tempo.start
    
    assert_equal(count_to, i)
    
    i = 0
    count_to = 1000
    
    tempo.on_tick { i += 100 }
    tempo.stop_when { i.eql?(count_to) }
    tempo.start
    
    assert_equal(count_to, i)

    
  end

end