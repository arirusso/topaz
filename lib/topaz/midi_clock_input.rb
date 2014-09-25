module Topaz
  
  # Trigger an event based on received midi clock messages
  class MIDIClockInput
      
    include Pausable

    attr_reader :clock, :listening, :running
    alias_method :listening?, :listening
    alias_method :running?, :running
  
    # @param [UniMIDI::Input] input
    # @param [Hash] options
    # @option options [Clock::Event] :event
    def initialize(input, options = {})
      @event = options[:event]
      @tick_counter = 0
      @pause = false
      @listening = false
      @running = false
      @tempo_calculator = TempoCalculator.new
      @tick_threshold = interval_to_ticks(options.fetch(:interval, 4))

      initialize_listener(input)
    end
    
    # This will return a calculated tempo
    # @return [Fixnum]
    def tempo
      @tempo_calculator.calculate
    end
    
    # Start the listener
    # @param [Hash] options
    # @option options [Boolean] :background Whether to run the listener in a background process
    # @option options [Boolean] :focus (or :blocking) Whether to run the listener in a foreground process
    # @return [MIDIInputClock] self
    def start(options = {})  
      @listening = true
      blocking = options[:focus] || options[:blocking]
      background = options[:background] || blocking.nil? || blocking.eql?(false)
      @listener.start(:background => background)
      self
    end
    
    # Stop the listener
    # @return [MIDIInputClock] self
    def stop(*a)
      @listening = false
      @listener.stop
      self
    end
    
    # Join the listener thread
    # @return [MIDIInputClock] self
    def join
      @listener.join
      self
    end
        
    # Change the clock interval
    # Defaults to 4, which means click once every 24 ticks or one quarter note (per MIDI spec).
    # Therefore, to fire the on_tick event twice as often, pass 8 
    #
    #   1 = whole note
    #   2 = half note
    #   4 = quarter note
    #   6 = dotted quarter
    #   8 = eighth note
    #  16 = sixteenth note
    #  etc
    #
    # @param [Fixnum] interval
    # @return [Fixnum]
    def interval=(interval)
      @tick_threshold = interval_to_ticks(interval)
    end
    
    # Return the interval at which the tick event is fired
    # @return [Fixnum]
    def interval
      ticks_to_interval(@tick_threshold)
    end
    
    private

    # Convert a note interval to number of ticks
    # @param [Fixnum] interval
    # @param [Fixnum]
    def interval_to_ticks(interval)
      per_qn = interval / 4
      24 / per_qn
    end

    # Convert a number of ticks to a note interval
    # @param [Fixnum] ticks
    # @param [Fixnum]
    def ticks_to_interval(ticks)
      note_value = 24 / ticks
      4 * note_value
    end
    
    # Initialize the MIDI input listener
    # @param [UniMIDI::Input] input
    # @return [MIDIEye::Listener]
    def initialize_listener(input)
      @listener = MIDIEye::Listener.new(input)
      @listener.listen_for(:name => "Clock") { |message| handle_clock_message(message) }     
      @listener.listen_for(:name => "Start") { handle_start_message } 
      @listener.listen_for(:name => "Stop") { handle_stop_message }
      @listener
    end

    # Handle a received start message
    # @return [Boolean]
    def handle_start_message
      @running = true
      if !@event.nil?
        @event.do_start
        true
      end
    end

    # Handle a received stop message
    # @return [Boolean]
    def handle_stop_message
      @running = false
      if !@event.nil?
        @event.do_stop
        true
      end
    end

    # Handle a received clock message
    # @param [Hash] message
    # @return [Fixnum] The current counter
    def handle_clock_message(message)
      @running ||= true
      thru
      log(message)
      tick? ? tick : advance
    end

    # Advance the tick counter
    # @return [Fixnum]
    def advance
      @tick_counter += 1
    end

    # Log the timestamp of a message for tempo calculation
    # @param [Hash] message
    # @return [Array<Fixnum>]
    def log(message)
      time = message[:timestamp] / 1000.0
      @tempo_calculator.timestamps << time
    end

    # Fire the clock event
    # (this results in MIDI output sending clock, thus thru)
    # @return [Boolean]
    def thru
      if !@event.nil?
        @event.do_clock
        true
      end
    end

    # Fire the tick event
    # @return [Boolean]
    def tick
      @tick_counter = 0
      if !@event.nil? && !@pause
        @event.do_tick
        true
      end
    end

    # Should the tick event be fired given the current state?
    # @return [Boolean]
    def tick?
      @tick_counter >= (@tick_threshold - 1)
    end
    
  end
  
end
