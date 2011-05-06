#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'
require 'unimidi'

UniMIDI::Output.last.open do |output|

  @tempo = Topaz::Tempo.new(132, :midi_output => output)

  @tempo.at(16) { @tempo.stop }
  
  @tempo.start

end

