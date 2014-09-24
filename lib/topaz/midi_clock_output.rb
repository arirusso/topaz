module Topaz
  
  # Send clock messages via MIDI
  class MIDIClockOutput

    # @param [Array<UniMIDI::Output>, UniMIDI::Output] output
    def initialize(output)
      @outputs = []
      add_output(output)
    end

    # Add a destination
    # @param [Array<UniMIDI::Output>, UniMIDI::Output] output
    # @return [Array<UniMIDI::Output>]
    def add_output(output)
      outputs = [output].flatten.compact
      @outputs += outputs
      @outputs
    end
    alias_method :add_outputs, :add_output

    # Remove a destination
    # @param [Array<UniMIDI::Output>, UniMIDI::Output] destinations
    # @return [Array<UniMIDI::Output>]
    def remove_output(output)
      outputs = [output].flatten.compact
      @outputs.delete_if { |output| outputs.include?(output) }
      @outputs
    end
    alias_method :remove_outputs, :remove_output
    
    # Send a start message
    # @return [Boolean] Whether a message was emitted
    def do_start(*a)
      start = MIDIMessage::SystemRealtime["Start"].new.to_a
      emit(start)
      !@outputs.empty?
    end

    # Send a stop message
    # @return [Boolean] Whether a message was emitted
    def do_stop(*a)
      stop = MIDIMessage::SystemRealtime["Stop"].new.to_a
      emit(stop)
      !@outputs.empty?
    end
        
    # Send a clock tick message
    # @return [Boolean] Whether a message was emitted
    def do_clock(*a)
      clock = MIDIMessage::SystemRealtime["Clock"].new.to_a
      emit(clock)
      !@outputs.empty?
    end

    private

    def emit(message)
      @outputs.each { |output| output.puts(message) }
    end
    
  end
  
end
