#!/usr/bin/env ruby
module Topaz
  
  module TempoSource
    
    def do_midi_clock
      @actions[:midi_clock].call
    end
    
    def do_tick
      @actions[:tick].call
    end
    
    def stop?
      !@actions[:stop_when].nil? && @actions[:stop_when].call
    end
   
  end
  
end