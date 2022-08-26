#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'topaz'

# A mock sequencer
class Sequencer
  def step
    @i ||= 0
    p "step #{@i += 1}"
  end
end

seq = Sequencer.new

# This sets quarter note = 132 bpm
@tempo = Topaz::Tempo.new(132) { seq.step }

puts 'Control-C to exit'
puts

@tempo.start
