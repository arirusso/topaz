module Topaz
  
  # Calculate tempo given timestamps
  class TempoCalculator

    THRESHOLD = 6 # Optimal number of ticks to analyze
    
    attr_reader :tempo, :timestamps
    
    def initialize
      @tempo = nil
      @timestamps = []
    end
    
    # Analyze the tempo based on the threshold
    # @return [Fixnum]
    def calculate
      tempo = nil
      if @timestamps.count >= 2
        @timestamps.slice!(-THRESHOLD.end, THRESHOLD.end)
        deltas = []
        @timestamps.each_with_index do |timestamp, i| 
          if i <= @timestamps.length - 1
            deltas << (@timestamps[i+1] - timestamp)
          end
        end
        sum = deltas.inject(&:+)
        average = sum.to_f / deltas.length
        bpm = ppq24_millis_to_bpm(average)
        @tempo = bpm
      end
    end
    
    private
    
    # Convert the raw tick intervals to beats-per-minute (BPM)
    # @param [Float] ppq24 
    # @return [Float]
    def ppq24_millis_to_bpm(ppq24)
      quarter_note = ppq24 * 24.to_f
      minute = 60 * 1000 # one minute in millis
      minute / quarter_note
    end
    
  end
  
end
