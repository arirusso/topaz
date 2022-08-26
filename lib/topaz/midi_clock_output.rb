# frozen_string_literal: true

module Topaz
  # Send clock messages via MIDI
  class MIDIClockOutput
    attr_reader :devices

    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :device
    def initialize(options)
      device = options[:device] || options[:devices]
      @devices = [device].flatten.compact
    end

    # Send a start message
    # @return [Boolean] Whether a message was emitted
    def do_start(*_args)
      start = MIDIMessage::SystemRealtime['Start'].new
      emit(start)
      !@devices.empty?
    end

    # Send a stop message
    # @return [Boolean] Whether a message was emitted
    def do_stop(*_args)
      stop = MIDIMessage::SystemRealtime['Stop'].new
      emit(stop)
      !@devices.empty?
    end

    # Send a clock tick message
    # @return [Boolean] Whether a message was emitted
    def do_clock(*_args)
      clock = MIDIMessage::SystemRealtime['Clock'].new
      emit(clock)
      !@devices.empty?
    end

    private

    # Emit a message to the devices
    # @param [MIDIMessage] message
    def emit(message)
      @devices.each { |device| device.puts(*message.to_bytes) }
    end
  end
end
