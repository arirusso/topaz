module Topaz

  class Timer < Gamelan::Timer

    attr_reader :phase, :running
    alias_method :running?, :running

    # @param [Fixnum] tempo
    # @param [Hash] options
    # @option options [Clock::Event] :event
    def initialize(tempo, options = {})
      @event = options[:event]
      @last_tick_event = 0
      @last_midi_clock = 0
      @running = false
      self.interval = options[:interval] || 4 
      
      super({ :tempo => tempo })
    end

    # Start the internal timer
    # @param [Hash] options
    # @option options [Boolean] :background Whether to run the timer in a background thread (default: false)
    # @return [Timer]
    def start(options = {})
      run
      join unless !!options[:background]
      self
    end
    
    # Set the timer's click interval
    # @param [Fixnum] value
    # @return [Fixnum]
    def interval=(value)
      @interval = value / 4
    end
    
    # The timer's click interval
    # @return [Fixnum]
    def interval
      @interval * 4
    end
    
    # Stop the timer
    # @return [Timer]
    def stop(*a)
      super()
      self
    end
    
    # Join the timer thread
    # @return [Timer]
    def join
      super()
      self
    end
    
    protected

    # Initialize the scheduler's clock, and begin executing tasks
    # @return [Boolean]
    def run
      unless @running
        @thread = Thread.new do
          @running = true
          begin
            @phase = 0.0
            @origin = @time = Time.now.to_f
            loop do 
              dispatch 
              advance
            end
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        @thread.abort_on_exception = true
        true
      else
        false
      end
    end 

    # Run all ready tasks.
    # @return [Boolean]
    def dispatch
      # Stuff to do on every tick      
      if time_for_midi_clock?
        # look for stop
        !@event.nil? && @event.do_clock        
        @last_midi_clock = (@phase * 24).to_i
        true
      end
      # Stuff to do on @interval
      if time_for_tick?
        !@event.nil? && @event.do_tick
        @last_tick_event = (@phase * @interval).to_i
        true
      end
    end
    
    private
    
    # Is the current phase appropriate for MIDI clock output?
    # @return [Boolean]
    def time_for_midi_clock?
      phase = (@phase * 24).to_i
      !@last_midi_clock.eql?(phase)
    end
    
    # Is the current phase appropriate for the tick event?
    # @return [Boolean]
    def time_for_tick?
      phase = (@phase * @interval).to_i
      !@last_tick_event.eql?(phase)
    end
     
  end
  
end
