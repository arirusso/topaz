#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'

UniMIDI::Output.first.open do |output|

  @tempo = Topaz::Tempo.new(132, :midi_output => output)

  @tempo.start

  @tempo.at(16) { @tempo.stop }

end

