module Topaz

  # The main tempo clock
  class Clock

    include API

    attr_reader :event, :midi_clock_output, :source, :trigger

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @param [Proc] tick_event
    def initialize(tempo_or_input, options = {}, &tick_event)
      # The MIDI clock output is initialized regardless of whether there are devices
      # so that it is ready if any are added during the running process.
      @midi_clock_output = MIDIClockOutput.new(:devices => options[:midi])
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

    # This will start the clock source
    #
    # In the case that external midi tempo is being used, this will instead start the process
    # of waiting for a start or clock message
    #
    # @param [Hash] options
    # @option options [Boolean] :background Whether to run the timer in a background thread (default: false)
    # @return [Boolean]
    def start(options = {})
      @start_time = Time.now
      begin
        @source.start(options)
      rescue SystemExit, Interrupt => exception
        stop
      end
      true
    end

    # This will stop the clock source
    # @param [Hash] options
    # @return [Boolean]
    def stop(options = {})
      @source.stop(options)
      @start_time = nil
      true
    end

    # Seconds since start was called
    # @return [Float]
    def time
      (Time.now - @start_time).to_f unless @start_time.nil?
    end

    private

    # Initialize the tick and MIDI clock events so that they can be passed to the source
    # and fired when needed
    # @param [Proc] block
    # @return [Clock::Event]
    def initialize_events(&block)
      @event.tick << block if block_given?
      clock = proc do 
        if @trigger.stop?
          stop
        else
          @midi_clock_output.do_clock
        end
      end
      @event.clock = clock
      @event.start << proc { @midi_clock_output.do_start }
      @event.stop << proc { @midi_clock_output.do_stop }
      @event
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

  Tempo = Clock # For backwards compat

end
