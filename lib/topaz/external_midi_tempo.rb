module Topaz
  
  # Trigger an event based on received midi clock messages
  class ExternalMIDITempo
    
    include TempoSource
   
    attr_reader :clock
  
    def initialize(actions, input, options = {})
      @actions = actions
      interval = options[:interval] || 4
      @tempo_calculator = TempoCalculator.new
      @clock = MIDIEye::Listener.new(input)
      
      initialize_clock 
    end
    
    # This will return a calculated tempo
    def tempo
      @tempo_calculator.find_tempo
    end
    
    def start(*a)      
      @clock.start(*a)
      self
    end
    
    def stop(*a)
      @clock.stop
      self
    end
    
    def join
      @clock.join
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
    def interval
      4 * (24 / @per_tick)
    end
    
    private
    
    def initialize_clock
      @counter = 0
      @clock.listen_for(:name => "Clock") do |msg|        
        (stop and return) if stop?
        do_midi_clock
        @tempo_calculator.timestamps << msg[:timestamp]
        if @counter.eql?(@per_tick)
          do_tick
          @counter = 0 
        else
          @counter += 1
        end
      end
    end
    
  end
  
end
