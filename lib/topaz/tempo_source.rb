module Topaz

  # Construct a tempo source
  module TempoSource

    extend self

    # Construct a tempo source
    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Tempo::Event] event
    # @param [Hash] options
    # @return [MIDIClockInput, Timer]
    def new(tempo_or_input, event, options)
      klass = case tempo_or_input
      when Numeric then Timer
      when UniMIDI::Input then MIDIClockInput
      else
        raise "Not a valid tempo source"
      end
      source = klass.new(event, tempo_or_input)
      source.interval = options[:interval] unless options[:interval].nil?
      source
    end

  end

end
