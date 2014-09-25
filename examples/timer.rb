#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), "../lib")

require "topaz"

# A mock sequencer
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

seq = Sequencer.new

# This sets quarter note = 132 bpm
@tempo = Topaz::Tempo.new(132) { seq.step }

puts "Control-C to exit"
puts

@tempo.start
