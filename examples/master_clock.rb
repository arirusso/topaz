#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')
dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../../alsa-rawmidi/lib'

require 'topaz'
require 'unimidi'

UniMIDI::Output.last.open do |output|

  @tempo = Topaz::Tempo.new(132, :midi_input => UniMIDI::Input.first.open, :midi_output => UniMIDI::Output.first.open)

  @tempo.at(64) { @tempo.stop }
  
  @tempo.start

end

