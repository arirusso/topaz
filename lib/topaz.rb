#
# Topaz
# MIDI syncable tempo in Ruby
#
# (c)2011-2015 Ari Russo
# Apache 2.0 License
#

# libs
require "forwardable"
require "gamelan"
require "midi-eye"
require "midi-message"

# modules
require "topaz/api"
require "topaz/pausable"
require "topaz/tempo_source"

# classes
require "topaz/clock"
require "topaz/midi_clock_input"
require "topaz/midi_clock_output"
require "topaz/tempo_calculator"
require "topaz/timer"

module Topaz

  VERSION = "0.2.5"

end
