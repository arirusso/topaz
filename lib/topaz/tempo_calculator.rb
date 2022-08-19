# frozen_string_literal: true

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
    # @return [Float, nil] The tempo as a float, or nil if there's not enough data to calculate it
    def calculate
      return unless @timestamps.count >= 2

      limit_timestamps
      deltas = calculate_deltas
      sum = deltas.inject(&:+)
      average = sum.to_f / deltas.count
      bpm = ppq24_millis_to_bpm(average)
      @tempo = bpm
    end

    private

    # Limit the timestamp list to within the threshold
    # @return [Array<Time>, nil]
    def limit_timestamps
      return unless @timestamps.count > THRESHOLD

      @timestamps.slice!(THRESHOLD - @timestamps.count, THRESHOLD)
      @timstamps
    end

    # Get the delta values between the timestamps
    # @return [Array<Float>]
    def calculate_deltas
      @timestamps.each_cons(2).map { |a, b| b - a }
    end

    # Convert the raw tick intervals to beats-per-minute (BPM)
    # @param [Float] ppq24
    # @return [Float]
    def ppq24_millis_to_bpm(ppq24)
      quarter_note = ppq24.to_f * 24.to_f
      60 / quarter_note
    end
  end
end
