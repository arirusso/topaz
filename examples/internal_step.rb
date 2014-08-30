#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), "../lib")

require "topaz"

# A mock sequencer for demonstration
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

seq = Sequencer.new

# This sets 8th note = 132 bpm.  The default value is quarter note (or 4)
@tempo = Topaz::Tempo.new(132, :interval => 8) { seq.step }
@tempo.start
