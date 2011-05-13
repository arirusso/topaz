module Topaz
  
  class TempoCalculator
    
    attr_reader :tempo
    
    def initialize(tempo = nil)
      @tempo = tempo
      @timestamps = []
      @counter = 0
    end
    
    def process(timestamp)
      @timestamps.shift if @timestamps.length > 48
      @timestamps << timestamp
      if @counter.eql?(23)
        diffs = []
        @timestamps.each_with_index { |n, i| (diffs << (@timestamps[i+1] - n)) unless @timestamps[i+1].nil? }
        unless diffs.empty?
          avg = (diffs.inject { |a, b| a + b }.to_f / diffs.length.to_f) 
          @tempo = ppq24_millis_to_bpm(avg)
        end 
        p @tempo
        @counter = 0
      else
        @counter += 1
      end
    end
    
    private
    
    def ppq24_millis_to_bpm(ppq24)
      quarter_note = (ppq24 * 24.to_f)
      minute = (60 * 1000) # one minute in millis
      minute/quarter_note
    end
    
  end
  
end