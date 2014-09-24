module Topaz
  
  # Trigger an event based on received midi clock messages
  class MIDIClockInput
      
    attr_reader :clock
  
    def initialize(event, input, options = {})
      @event = event
      @tempo_calculator = TempoCalculator.new
      interval = options[:interval] || 4

      initialize_listener(input)
    end
    
    # This will return a calculated tempo
    def tempo
      @tempo_calculator.find_tempo
    end
    
    def start(*a)      
      @listener.start(*a)
      self
    end
    
    def stop(*a)
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
        @event.do_clock # thru
        @tempo_calculator.timestamps << message[:timestamp]
        if @counter.eql?(@per_tick)
          @event.do_tick
          @counter = 0 
        else
          @counter += 1
        end
      end
    end
    
  end
  
end
