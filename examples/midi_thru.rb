#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'topaz'
require 'unimidi'

# Sync to a MIDI input, and send MIDI clock to an output

# Select MIDI input and output
@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets

# Mock sequencer
class Sequencer
  def step
    @i ||= 0
    p "step #{@i += 1}"
  end
end

sequencer = Sequencer.new
@tempo = Topaz::Clock.new(@input, midi: [@output]) { sequencer.step }

puts 'Waiting for MIDI clock...'
puts 'Control-C to exit'
puts

@tempo.start
