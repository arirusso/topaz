#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

require "topaz"

# Receive MIDI clock messages

# A mock sequencer
class Sequencer

  def step
    @i ||= 0
    p "step #{@i+=1}"
  end

end

# Select a MIDI input
@input = UniMIDI::Input.gets

sequencer = Sequencer.new

@tempo = Topaz::Clock.new(@input) do
  sequencer.step
  puts "tempo: #{@tempo.tempo}"
end

puts "Waiting for MIDI clock..."
puts "Control-C to exit"
puts

@tempo.start
