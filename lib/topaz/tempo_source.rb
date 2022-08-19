# frozen_string_literal: true

module Topaz
  # Construct a tempo source object
  module TempoSource
    module_function

    # Construct a tempo source
    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Clock::Event] :event
    # @option options [Boolean] :midi_transport Whether to respect start/stop commands when the input is MIDI
    # @return [MIDIClockInput, Timer]
    def new(tempo_or_input, options = {})
      klass = if tempo_or_input.is_a?(Numeric)
                Timer
              elsif defined?(UniMIDI) && tempo_or_input.is_a?(UniMIDI::Input)
                MIDIClockInput
              else
                raise 'Not a valid tempo source'
              end
      klass.new(tempo_or_input, options)
    end
  end
end
