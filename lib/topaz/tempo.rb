module Topaz
  
  # Main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source, :destinations
    
    def_delegators :source, :tempo, :interval, :interval=, :join
  
    def initialize(tempo_or_input, options = {}, &tick_event)
      @paused = false
      @destinations = [] 
      @events = Events.new

      configure(tempo_or_input, options, &tick_event)     
    end
    
    # Change the tempo
    #
    # Caution that in the case that external MIDI tempo is being used, this will switch to internal 
    # tempo at the desired rate.
    #
    def tempo=(val)
      if @source.respond_to?(:tempo=)
        @source.tempo = val
      else
        @source = InternalTempo.new(@events, val)
      end 
    end
    
    # Pause the clock
    def pause
      @pause = true
    end
    
    # Unpause the clock
    def unpause
      @pause = false
    end
    
    # Is this clock paused?
    def paused?
      @pause
    end
   
    # Toggle pausing the clock
    def toggle_pause
      paused? ? unpause : pause      
    end
    
    # Pass in a callback that is called when start is called
    def on_start(&callback)
      @events.start[0] = callback
    end

    # pass in a callback that is called when stop is called
    def on_stop(&callback)
      @events.stop[0] = callback
    end
    
    # Pass in a callback which will stop the clock if it evaluates to true 
    def stop_when(&callback)
      @events.stop_when = callback
    end
    
    # Pass in a callback which will be fired on each tick
    def on_tick(&callback)
      wrapper = proc do
        unless paused?
          yield
        end
      end
      @events.tick[0] = wrapper
    end
        
    # this will start the generator
    #
    # in the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    def start(options = {})
      begin
        @start_time = Time.now
        @events.do_start
        @source.start(options)
      rescue SystemExit, Interrupt => exception
        stop
      end
    end
    
    # This will stop the clock
    def stop(options = {})
      @source.stop(options)
      @events.do_stop
      @start_time = nil
    end
    
    # Seconds since start was called
    def time
      (Time.now - @start_time).to_f unless @start_time.nil?
    end
    alias_method :time_since_start, :time
    
    # Add a destination
    # @param [Array<UniMIDI::Output>, UniMIDI::Output] destinations
    def add_destination(destinations)
      destinations = [destinations].flatten.compact
      destinations.each do |destination|
        output = MIDISyncOutput.new(destination) 
        @destinations << output
      end
    end

    # Remove a destination
    # @param [Array<UniMIDI::Output>, UniMIDI::Output] destinations
    def remove_destination(destinations)
      destinations = [destinations].flatten.compact
      destinations.each do |output|
        @destinations.each do |sync_output|
          @destinations.delete(sync_output) if sync_output.output == output
        end
      end
    end
            
    private
        
    def initialize_destinations(midi_outputs)
      midi_outputs = [midi_outputs].flatten.compact
      midi_outputs.each do |output|
        add_destination(output)
      end
    end

    def initialize_midi_clock_output
      [:clock, :start, :stop].each do |event|
        action = proc do
          @destinations.each { |destination| destination.send(event) }
        end
        @events.send("midi_#{event.to_s}=", action)
      end
    end

    def initialize_tempo_source(tempo_or_input)
      @source = case tempo_or_input
        when Numeric then InternalTempo.new(@events, tempo_or_input)
        when UniMIDI::Input then ExternalMIDITempo.new(@events, tempo_or_input)
      else
        raise "You must specify an internal tempo rate or an external tempo source"
      end
    end

    def configure(tempo_or_input, options = {}, &tick_event)
      initialize_tempo_source(tempo_or_input)     
      initialize_destinations(options[:midi]) unless options[:midi].nil?
      initialize_midi_clock_output
      @source.interval = options[:interval] unless options[:interval].nil? 
      on_tick(&tick_event)
    end
    
  end
  
end
