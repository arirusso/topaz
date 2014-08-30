#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), "../lib")

require "topaz"

# This example will sync to a MIDI input, as well as send the sync messages to another output

# First, have the user select MIDI input and output
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
@tempo = Topaz::Tempo.new(@input, :midi => [@output]) { sequencer.step }
@tempo.start
