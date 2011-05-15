#!/usr/bin/env ruby

$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'
require 'unimidi'

input = UniMIDI::Input.first.open
output = UniMIDI::Output.first.open

@tempo = Topaz::Tempo.new(132, :midi_input => input, :midi_output => output)
  
@tempo.wait_for_midi_start

