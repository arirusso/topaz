#!/usr/bin/env ruby
#
# MIDI syncable tempo module in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'forwardable'
require 'gamelan'
require 'midi-eye'

require 'topaz/external_midi_tempo'
require 'topaz/internal_tempo'
require 'topaz/tempo_calculator'
require 'topaz/tempo'

module Topaz
  
  VERSION = "0.0.1"
  
end