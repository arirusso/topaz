#
# MIDI syncable tempo module in Ruby
# (c)2011-2014 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"
require "gamelan"
require "midi-eye"
require "midi-message"

# classes
require "topaz/events"
require "topaz/external_midi_tempo"
require "topaz/internal_tempo"
require "topaz/midi_sync_output"
require "topaz/tempo_calculator"
require "topaz/tempo"

module Topaz
  
  VERSION = "0.1.2"
  
end
