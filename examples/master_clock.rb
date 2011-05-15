#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')
dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../../alsa-rawmidi/lib'
$LOAD_PATH.unshift dir + '/../../midi-eye/lib'

require 'topaz'
require 'unimidi'

input = UniMIDI::Input.first.open
output = UniMIDI::Output.first.open

@tempo = Topaz::Tempo.new(132, :midi_input => input, :midi_output => output)

#@tempo.at(64) { @tempo.stop }
  
@tempo.wait_for_midi_start

