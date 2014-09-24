module Topaz

  # Main tempo class
  class Tempo

    extend Forwardable

    attr_reader :event, :midi_clock_output, :source, :trigger
    def_delegators :source, :tempo, :interval, :interval=, :join

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @param [Proc] tick_event
    def initialize(tempo_or_input, options = {}, &tick_event)
      @paused = false
      @midi_clock_output = MIDIClockOutput.new(options[:midi])
      @event = Event.new
      @trigger = EventTrigger.new
      @source = TempoSource.new(tempo_or_input, options.merge({ :event => @event })) 
      initialize_events(&tick_event)
    end

    # Set the tempo
    #
    # If external MIDI tempo is being used, this will switch to internal tempo at the desired rate.
    #
    # @param [Fixnum] value
    # @return [ExternalMIDITempo, InternalTempo]
    def tempo=(value)
      if @source.respond_to?(:tempo=)
        @source.tempo = value
      else
        @source = TempoSource.new(event, tempo_or_input)
      end
    end

    # Pause the clock
    # @return [Boolean]
    def pause
      @pause = true
    end

    # Unpause the clock
    # @return [Boolean]
    def unpause
      @pause = false
    end

    # Is this clock paused?
    # @return [Boolean]
    def paused?
      @pause
    end

    # Toggle pausing the clock
    # @return [Boolean]
    def toggle_pause
      paused? ? unpause : pause      
    end

    # This will start the generator
    #
    # In the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    # @param [Hash] options
    # @return [Boolean]
    def start(options = {})
      @start_time = Time.now
      begin
        @midi_clock_output.do_start
        @event.do_start
        @source.start(options)
      rescue SystemExit, Interrupt => exception
        stop
      end
      true
    end

    # This will stop the clock
    # @param [Hash] options
    # @return [Boolean]
    def stop(options = {})
      @source.stop(options)
      @midi_clock_output.do_stop
      @event.do_stop
      @start_time = nil
      true
    end

    # Seconds since start was called
    # @return [Float]
    def time
      (Time.now - @start_time).to_f unless @start_time.nil?
    end
    alias_method :time_since_start, :time

    private

    def initialize_events(&block)
      wrapper = proc do 
        if block_given? && !paused?
          yield
        end
      end
      @event.tick << wrapper
      clock = proc do 
        (stop and return) if @trigger.stop?
        @midi_clock_output.do_clock
      end
      @event.clock = clock
    end

    # Trigger clock events
    class EventTrigger

      def initialize
        @stop = []
      end

      # Pass in a callback which will stop the clock if it evaluates to true
      # @param [Proc] callback
      # @return [Array<Proc>]
      def stop(&callback)
        if block_given?
          @stop.clear
          @stop << callback
        end
        @stop
      end

      # Should the stop event be triggered?
      # @return [Boolean]
      def stop?
        !@stop.nil? && @stop.any?(&:call)
      end

    end

    # Clock events
    class Event

      attr_accessor :clock

      def initialize
        @start = []
        @stop = []
        @tick = []
      end

      # @return [Array]
      def do_clock
        !@clock.nil? && @clock.call
      end

      # Pass in a callback that is called when start is called
      # @param [Proc] callback
      # @return [Array<Proc>]
      def start(&callback)
        if block_given?
          @start.clear
          @start << callback
        end
        @start
      end

      # @return [Array]
      def do_start
        @start.map(&:call)
      end

      # pass in a callback that is called when stop is called
      # @param [Proc] callback
      # @return [Array<Proc>]
      def stop(&callback)
        if block_given?
          @stop.clear
          @stop << callback
        end
        @stop
      end

      # @return [Array]
      def do_stop
        @stop.map(&:call)
      end

      # Pass in a callback which will be fired on each tick
      # @param [Proc] callback
      # @return [Array<Proc>]
      def tick(&callback)
        if block_given?
          @tick.clear
          @tick << callback
        end
        @tick
      end

      # @return [Array]
      def do_tick
        @tick.map(&:call)
      end

    end

  end

end
