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
        limit_timestamps
        deltas = get_deltas
        sum = deltas.inject(&:+)
        average = sum.to_f / deltas.length
        bpm = ppq24_millis_to_bpm(average)
        @tempo = bpm
      end
    end
    
    private

    # Limit the timestamp list to within the threshold
    # @return [Array<Time>]
    def limit_timestamps
      if @timestamps.count > THRESHOLD
        @timestamps.slice!(THRESHOLD - @timestamps.count, THRESHOLD)
      end
    end

    # Get the delta values between the timestamps
    # @return [Array<Fixnum>]
    def get_deltas
      deltas = []
      @timestamps.each_with_index do |timestamp, i| 
        if timestamp != @timestamps.last
          next_timestamp = @timestamps[i+1]
          deltas << (next_timestamp - timestamp)
        end
      end
      deltas
    end

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
