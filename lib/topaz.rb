#!/usr/bin/env ruby
#
# MIDI Tempo + Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'forwardable'
require 'gamelan'
require 'midi-message'
require 'nibbler'

require 'topaz/observes_midi'
require 'topaz/tempo'
require 'topaz/tempo_calculator'

module Topaz
  
  VERSION = "0.0.1"
  
end