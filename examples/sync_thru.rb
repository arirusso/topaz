#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')
require 'topaz'
# this example will sync to a MIDI input, as well as send the sync messages to another output

# first, initialize the MIDI input port
@input = UniMIDI::Input.first.open
# initialize the midi output to send sync to
@output = UniMIDI::Output.first.open

# a fake little sequencer for demonstration
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

seq = Sequencer.new
@tempo = Topaz::Tempo.new(:midi => [@input, @output]) { seq.step }
@tempo.start
