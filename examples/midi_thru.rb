#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), "../lib")

require "topaz"

# Sync to a MIDI input, and send MIDI clock to an output

# Select MIDI input and output
@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

# Mock sequencer
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

sequencer = Sequencer.new
@tempo = Topaz::Clock.new(@input, :midi => [@output]) { sequencer.step }

puts "Waiting for MIDI clock..."
puts "Control-C to exit"
puts

@tempo.start
