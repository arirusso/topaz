#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'

# a mock sequencer for demonstration
class Sequencer
  
  def step(instance)
    @i ||= 0
    p "instance: #{instance}, step: #{@i+=1}"
  end
  
end

seq = Sequencer.new

# this sets 8th note = 132 bpm.  the default value is quarter note (or 4)
@tempo = Topaz::Tempo.new(132, :interval => 8) { seq.step(1) }
@tempo2 = Topaz::Tempo.new(180, :interval => 8, :children => @tempo) { seq.step(2) }
#@tempo.start(:background => true)
@tempo2.start
