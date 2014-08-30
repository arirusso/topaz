module Topaz
  
  # User defined callbacks for tempo events
  class Events

    attr_reader :tick
    attr_accessor :midi_clock, :midi_start, :midi_stop, :start, :stop, :stop_when

    def initialize()
      @start = []
      @stop = []
      @tick = [] 

      @midi_clock = nil
      @midi_start = nil
      @midi_stop = nil
      @stop_when = nil
    end
    
    def do_midi_clock
      @midi_clock.call
    end

    def do_start
      @midi_start.call
      @start.each(&:call)
    end

    def do_stop
      @midi_stop.call
      @stop.each(&:call)
    end
    
    def do_tick
      @tick.each(&:call)
    end
    
    def stop?
      @stop_when.call unless @stop_when.nil?
    end
   
  end
  
end
