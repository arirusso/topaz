#!/usr/bin/env ruby
module Topaz
  
  # main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source
    
    def_delegators :source, :tempo, :interval, :interval=
  
    def initialize(*args, &event)
      @destinations = []
      
      if args.first.kind_of?(Numeric)
        @source = InternalTempo.new(args.shift)
      end
      options = args.first
      
      initialize_midi_io(options)
      raise "You must specify an internal tempo rate or an external tempo source" if @source.nil?
      @source.action = { :on_tick => event, :destinations => @destinations }
      @source.interval = options[:interval] unless options[:interval].nil? 
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
      @on_start = block
    end

    # pass in a callback that is called when stop is called
    def on_stop(&block)
      @on_stop = block
    end
        
    # this will start the generator
    #
    # in the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    def start(options = {})
      @start_time = Time.now
      @destinations.each { |dest| dest.on_start }
      @on_start.call unless @on_start.nil?
      @source.start(options)
    end
    
    # this will stop tempo
    def stop(options = {})
      @destinations.each { |dest| dest.on_stop }
      @on_stop.call unless @on_stop.nil?
      @source.stop(options)
    end
    
    # seconds since start was called
    def time_since_start
      @start_time.nil? ? nil : (Time.now - @start_time).to_f
    end
    
    private
        
    def initialize_midi_io(args)
      ports = args.kind_of?(Hash) ? args[:midi] : args
      unless ports.nil?
        if ports.kind_of?(Array) 
          ports.each { |port| initialize_midi_io(port) }
        elsif ports.type.eql?(:input) && @source.nil?
          @source = ExternalMIDITempo.new(ports) 
        elsif ports.type.eql?(:output)
          @destinations << MIDISyncOutput.new(ports)
        end
      end
    end    
    
  end
  
end