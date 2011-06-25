#!/usr/bin/env ruby
module Topaz
  
  # main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source
    
    def_delegators :source, :tempo, :interval, :interval=, :join
  
    def initialize(*args, &event)
      @destinations = []
      @actions = { 
        :on_start => nil,
        :on_stop => nil,
        :on_tick => event,        
        :on_midi_clock => Proc.new { @destinations.each { |d| d.on_tick } },
        :stop_when => nil
      }

      if args.first.kind_of?(Numeric)
        @source = InternalTempo.new(@actions, args.shift)
      end
      options = args.first
      
      initialize_midi_io(options)
      raise "You must specify an internal tempo rate or an external tempo source" if @source.nil?
      
      @source.interval = options[:interval] unless options.nil? || options[:interval].nil? 
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
    
    # pass in a callback that is called when start is called
    def on_start(&block)
      @actions[:on_start] = block
    end

    # pass in a callback that is called when stop is called
    def on_stop(&block)
      @actions[:on_stop] = block
    end
    
    # pass in a callback which will 
    def stop_when(&block)
      @actions[:stop_when] = block
    end
    
    # pass in a callback which will be fired on each tick
    def on_tick(&block)
      @actions[:on_tick] = block
    end
        
    # this will start the generator
    #
    # in the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    def start(options = {})
      @start_time = Time.now
      @destinations.each { |dest| dest.on_start }
      @source.start(options)
      @actions[:on_start].call unless @actions[:on_start].nil?
    end
    
    # this will stop tempo
    def stop(options = {})
      @destinations.each { |dest| dest.on_stop }
      @source.stop(options)
      @actions[:on_stop].call unless @actions[:on_stop].nil?
      @start_time = nil
    end
    
    # seconds since start was called
    def time
      @start_time.nil? ? nil : (Time.now - @start_time).to_f
    end
    alias_method :time_since_start, :time
    
    def tick
      
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