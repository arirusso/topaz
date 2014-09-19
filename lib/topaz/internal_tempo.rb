module Topaz

  class InternalTempo < Gamelan::Timer
            
    def initialize(events, tempo, options = {})
      @events = events
      @last = 0
      @last_sync = 0
      self.interval = options[:interval] || 4 
      
      super({:tempo => tempo})
    end

    # start the internal timer
    # pass :background => true to keep the timer in a background thread
    def start(options = {})
      run
      join unless !!options[:background]
      self
    end
    
    # change the timer's click interval    
    def interval=(val)
      @interval = val / 4
    end
    
    def interval
      @interval * 4
    end
    
    # stop the timer
    def stop(*a)
      super()
      self
    end
    
    def join
      super()
      self
    end
    
    protected

    # Initialize the scheduler's clock, and begin executing tasks.
    def run
      return if @running
      @running  = true
      @thread   = Thread.new do
        begin
          @phase  = 0.0
          @origin = @time = Time.now.to_f
          loop { dispatch; advance }
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      @thread.abort_on_exception = true
    end 

    # Run all ready tasks.
    def dispatch
      # stuff to do on every tick      
      if time_for_midi_clock?
        # look for stop
        (stop and return) if @events.stop?
        @events.do_midi_clock        
        @last_sync = (@phase * 24).to_i
      end
      # stuff to do on @interval
      if time_for_tick?
        @events.do_tick
        @last = (@phase * @interval).to_i
      end      
    end
    
    private
    
    def time_for_midi_clock?
      !@last_sync.eql?((@phase * 24).to_i)
    end
    
    def time_for_tick?
      !@last.eql?((@phase * @interval).to_i)
    end
     
  end
  
end
