#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'

# first, initialize the MIDI input port
@input = UniMIDI::Input.first.open

# a mock sequencer for demonstration
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

seq = Sequencer.new
@tempo = Topaz::Tempo.new(@input) { seq.step; p "tempo: #{@tempo.tempo}" }
@tempo.start
