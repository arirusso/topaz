# frozen_string_literal: true

#
# Topaz
# MIDI syncable tempo in Ruby
#
# (c)2011-2022 Ari Russo
# Apache 2.0 License
#

# libs
require 'forwardable'
require 'midi-message'

# modules
require 'topaz/api'
require 'topaz/pausable'
require 'topaz/tempo_source'

# classes
require 'topaz/clock'
require 'topaz/midi_clock_input'
require 'topaz/midi_clock_output'
require 'topaz/tempo_calculator'
require 'topaz/gamelan_timer'
require 'topaz/timer'

module Topaz
  VERSION = '0.2.5'
end
