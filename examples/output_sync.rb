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

# Have the user select a MIDI output
@output = UniMIDI::Output.gets

sequencer = Sequencer.new

# This sets 8th note = 132 bpm.  the default value is quarter note (or 4)
@tempo = Topaz::Tempo.new(132, :interval => 8, :midi => @output) { sequencer.step }
@tempo.start
