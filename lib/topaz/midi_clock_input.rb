module Topaz
  
  # Trigger an event based on received midi clock messages
  class MIDIClockInput
      
    include Pausable

    attr_reader :clock, :running
    alias_method :running?, :running
  
    # @param [UniMIDI::Input] input
    # @param [Hash] options
    # @option options [Clock::Event] :event
    def initialize(input, options = {})
      @event = options[:event]
      @counter = 0
      @pause = false
      @running = false
      @tempo_calculator = TempoCalculator.new
      @per_tick = interval_to_tick(options.fetch(:interval, 4))

      initialize_listener(input)
    end
    
    # This will return a calculated tempo
    # @return [Fixnum]
    def tempo
      @tempo_calculator.calculate
    end
    
    # Start the listener
    # @return [MIDIInputClock] self
    def start(*a)  
      @running = true
      @listener.start(*a)
      self
    end
    
    # Stop the listener
    # @return [MIDIInputClock] self
    def stop(*a)
      @running = false
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
    # Defaults to click once every 24 ticks or one quarter note which is the MIDI standard.
    # However, if you wish to fire the on_tick event twice as often, pass 8 
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
      @per_tick = interval_to_tick(interval)
    end
    
    # Return the interval at which the tick event is fired
    # @return [Fixnum]
    def interval
      tick_to_interval(@per_tick)
    end
    
    private

    def interval_to_tick(interval)
      per_qn = interval / 4
      24 / per_qn
    end

    def tick_to_interval(tick)
      note_value = 24 / tick
      4 * note_value
    end
    
    # Initialize the MIDI input listener
    # @param [UniMIDI::Input] input
    # @return [MIDIEye::Listener]
    def initialize_listener(input)
      @listener = MIDIEye::Listener.new(input)
      # Note that this doesn't wait for a start signal
      @listener.listen_for(:name => "Clock") { |message| handle_clock_message(message) }     
      @listener
    end

    def handle_clock_message(message)
      thru
      log(message)
      if tick?
        tick
        @counter = 0 
      else
        @counter += 1
      end
    end

    def log(message)
      @tempo_calculator.timestamps << message[:timestamp]
    end

    def thru
      !@event.nil? && @event.do_clock
    end

    def tick
      !@event.nil? && !@pause && @event.do_tick
    end

    def tick?
      @counter.eql?(@per_tick)
    end
    
  end
  
end
