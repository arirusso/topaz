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

# First, have the user select a MIDI port
@input = UniMIDI::Input.gets

sequencer = Sequencer.new

@tempo = Topaz::Tempo.new(@input) do 
  sequencer.step 
  puts "tempo: #{@tempo.tempo}"
end

puts "Waiting for MIDI clock..."
@tempo.start
