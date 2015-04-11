#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

require "topaz"

# Send MIDI clock messages to a MIDI output

# A mock sequencer
class Sequencer

  def step
    @i ||= 0
    p "step #{@i+=1}"
  end

end

# Select a MIDI output
@output = UniMIDI::Output.gets

sequencer = Sequencer.new

# This sets quarter note = 132 bpm.
@tempo = Topaz::Tempo.new(132, :midi => @output) { sequencer.step }

puts "Control-C to exit"
puts

@tempo.start
