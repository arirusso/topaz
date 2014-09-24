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
      @pause = false
      @running = false
      @tempo_calculator = TempoCalculator.new
      self.interval = options.fetch(:interval, 4)

      initialize_listener(input)
    end
    
    # This will return a calculated tempo
    # @return [Fixnum]
    def tempo
      @tempo_calculator.calculate
    end
    
    def start(*a)  
      @running = true
      @listener.start(*a)
      self
    end
    
    def stop(*a)
      @running = false
      @listener.stop
      self
    end
    
    def join
      @listener.join
      self
    end
        
    #
    # change the clock interval
    # defaults to click once every 24 ticks or one quarter note which is the MIDI standard.
    # however, if you wish to fire the on_tick event twice as often 
    # (or once per 12 clicks), pass 8 
    #
    #   1 = whole note
    #   2 = half note
    #   4 = quarter note
    #   6 = dotted quarter
    #   8 = eighth note
    #  16 = sixteenth note
    #  etc
    #
    def interval=(val)
      per_qn = val / 4
      @per_tick = 24 / per_qn
    end
    
    # Return the interval at which the tick event is fired
    # @return [Fixnum]
    def interval
      4 * (24 / @per_tick)
    end
    
    private
    
    def initialize_listener(input)
      @listener = MIDIEye::Listener.new(input)
      @counter = 0
      # Note that this doesn't wait for a start signal
      @listener.listen_for(:name => "Clock") do |message|        
        !@event.nil? && @event.do_clock # thru
        @tempo_calculator.timestamps << message[:timestamp]
        if @counter.eql?(@per_tick)
          !@event.nil? && !@pause && @event.do_tick
          @counter = 0 
        else
          @counter += 1
        end
      end
    end
    
  end
  
end
