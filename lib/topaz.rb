#!/usr/bin/env ruby
#
# MIDI syncable tempo module in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'forwardable'
require 'gamelan'
require 'midi-eye'
require 'midi-message'

require 'topaz/tempo_source'
require 'topaz/external_midi_tempo'
require 'topaz/internal_tempo'
require 'topaz/midi_sync_output'
require 'topaz/tempo_calculator'
require 'topaz/tempo'

module Topaz
  
  VERSION = "0.0.11"
  
end