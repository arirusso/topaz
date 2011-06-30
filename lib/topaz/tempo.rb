#!/usr/bin/env ruby
module Topaz
  
  # main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source, :destinations
    
    def_delegators :source, :tempo, :interval, :interval=, :join
  
    def initialize(*args, &event)
      @paused = false
      @destinations = []      
      @actions = { 
        :start => nil,
        :stop => nil,
        :tick => nil,        
        :midi_clock => Proc.new { @destinations.each { |d| d.send(:midi_clock) if d.respond_to?(:midi_clock) } },
        :stop_when => nil
      }
      
      on_tick(&event)

      if args.first.kind_of?(Numeric)
        @source = InternalTempo.new(@actions, args.shift)
      end
      options = args.first
      
      initialize_midi_io(options)
      raise "You must specify an internal tempo rate or an external tempo source" if @source.nil?
      
      unless options.nil?        
        @source.interval = options[:interval] unless options[:interval].nil?      
      end
      
    end
    
    # this will change the tempo
    #
    # be warned, in the case that external midi tempo is being used, this will switch to internal 
    # tempo at the desired rate
    #
    def tempo=(val)
      if @source.respond_to?(:tempo=)
        @source.tempo = val
      else
        @source = InternalTempo.new(tempo, @action)
      end 
    end
    
    # pause the clock
    def pause
      @pause = true
    end
    
    # unpause the clock
    def unpause
      @pause = false
    end
    
    # is this clock paused?
    def paused?
      @pause
    end
   
    def toggle_pause
      paused? ? unpause : pause      
    end
    
    # pass in a callback that is called when start is called
    def on_start(&block)
      @actions[:start] = block
    end

    # pass in a callback that is called when stop is called
    def on_stop(&block)
      @actions[:stop] = block
    end
    
    # pass in a callback which will stop the clock if it evaluates to true 
    def stop_when(&block)
      proc = Proc.new do
        if yield
          stop
          true
        else
          false
        end 
      end
      @actions[:stop_when] = proc
    end
    
    # pass in a callback which will be fired on each tick
    def on_tick(&block)
      proc = Proc.new do
        unless paused?
          @destinations.each { |d| d.send(:tick) if d.respond_to?(:tick) }
          yield
        end
      end
      @actions[:tick] = proc
    end
        
    # this will start the generator
    #
    # in the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    def start(options = {})
      @start_time = Time.now
      @destinations.each { |dest| dest.start }
      @source.start(options)
      @actions[:start].call unless @actions[:start].nil?
    end
    
    # this will stop tempo
    def stop(options = {})
      @destinations.each { |dest| dest.stop }
      @source.stop(options)
      @actions[:stop].call unless @actions[:stop].nil?
      @start_time = nil
    end
    
    # seconds since start was called
    def time
      @start_time.nil? ? nil : (Time.now - @start_time).to_f
    end
    alias_method :time_since_start, :time
    
    # add a destination
    # accepts UniMIDI::Output or array of
    def add_destination(dest)
      dest = [dest].flatten.compact
      dest.each do |d|
        @destinations << MIDISyncOutput.new(d)
      end
    end

    # remove a destination
    # accepts UniMIDI::Output or array of
    def remove_destination(dest)
      dest = [dest].flatten.compact
      dest.each do |output|
        @destinations.each do |sync_output|
          @destinations.delete(sync_output) if sync_output.output == output
        end
      end
    end
        
    protected
    
    def tick
      @actions[:tick].call
    end
    
    private
        
    def initialize_midi_io(args)
      ports = args.kind_of?(Hash) ? args[:midi] : args
      unless ports.nil?
        if ports.kind_of?(Array) 
          ports.each { |port| initialize_midi_io(port) }
        elsif ports.type.eql?(:input) && @source.nil?
          @source = ExternalMIDITempo.new(@actions, ports) 
        elsif ports.type.eql?(:output)
          @destinations << MIDISyncOutput.new(ports)
        end
      end
    end    
    
  end
  
end