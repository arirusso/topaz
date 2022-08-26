#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'topaz'
require 'unimidi'

# Receive MIDI clock messages

# A mock sequencer
class Sequencer
  def step
    @i ||= 0
    p "step #{@i += 1}"
  end
end

# Select a MIDI input
@input = UniMIDI::Input.gets

sequencer = Sequencer.new

@tempo = Topaz::Clock.new(@input, midi_transport: true) do
  sequencer.step
  puts "tempo: #{@tempo.tempo}"
end

puts 'Waiting for MIDI clock...'
puts 'Control-C to exit'
puts

@tempo.start
