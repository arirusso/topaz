#!/usr/bin/env ruby
module Topaz
  
  class TempoCalculator
    
    attr_reader :tempo, :timestamps
    
    def initialize(tempo = nil)
      @tempo = tempo
      @timestamps = []
      @counter = 0
    end
    
    # analyse the tempo based on the last 24 ticks
    def find_tempo
      tempo = nil
      diffs = []
      @timestamps.shift while @timestamps.length > 24
      @timestamps.each_with_index { |n, i| (diffs << (@timestamps[i+1] - n)) unless @timestamps[i+1].nil? }
      unless diffs.empty?
        avg = (diffs.inject { |a, b| a + b }.to_f / diffs.length.to_f) 
        tempo = ppq24_millis_to_bpm(avg)
      end 
      @tempo = tempo
    end
    
    private
    
    # convert the raw tick intervals to bpm
    def ppq24_millis_to_bpm(ppq24)
      quarter_note = (ppq24 * 24.to_f)
      minute = (60 * 1000) # one minute in millis
      minute/quarter_note
    end
    
  end
  
end