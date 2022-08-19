# frozen_string_literal: true

module Topaz
  # Main Tempo/Timer class that serves as the interface for the user
  class Timer < Gamelan::Timer
    include Pausable

    attr_reader :phase, :running
    alias running? running

    # @param [Fixnum] tempo
    # @param [Hash] options
    # @option options [Clock::Event] :event
    def initialize(tempo, options = {})
      @event = options[:event]
      @last_tick_event = 0
      @last_midi_clock = 0
      @pause = false
      @running = false
      self.interval = options[:interval] || 4

      super({ tempo: tempo })
    end

    # Start the internal timer
    # @param [Boolean] background Whether to run the timer in a background thread (default: false)
    # @return [Timer]
    def start(background: false)
      run
      !@event.nil? && @event.do_start
      join unless background
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
    def stop(*_args)
      super()
      !@event.nil? && @event.do_stop
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
      return false if @running

      @thread = create_timer_thread
      @thread.abort_on_exception = true
      true
    end

    # Run all ready tasks.
    # @return [Boolean]
    def dispatch
      # Stuff to do on every tick
      clock if clock?
      # Stuff to do on @interval
      tick if tick?
      true
    end

    private

    def create_timer_thread
      Thread.new do
        begin
          initialize_running_state
          loop { perform }
        rescue StandardError => e
          Thread.main.raise(e)
        end
      end
    end

    # Perform the timer function
    # @return [Boolean]
    def perform
      dispatch
      advance
      true
    end

    # Perform a tick
    # @return [Boolean]
    def tick
      !@event.nil? && !@pause && @event.do_tick
      @last_tick_event = (@phase * @interval).to_i
      true
    end

    # Perform MIDI clock
    # @return [Boolean]
    def clock
      !@event.nil? && @event.do_clock
      @last_midi_clock = (@phase * 24).to_i
      true
    end

    # Initialize the variables that handle the running process of the timer
    # @return [Boolean]
    def initialize_running_state
      @running = true
      @phase = 0.0
      @origin = @time = Time.now.to_f
      true
    end

    # Is the current phase appropriate for MIDI clock output?
    # @return [Boolean]
    def clock?
      phase = (@phase * 24).to_i
      @last_midi_clock != phase
    end

    # Is the current phase appropriate for the tick event?
    # @return [Boolean]
    def tick?
      phase = (@phase * @interval).to_i
      @last_tick_event != phase
    end
  end
end
