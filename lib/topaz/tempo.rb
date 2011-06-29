#!/usr/bin/env ruby
module Topaz
  
  # main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source, :destinations
    
    def_delegators :source, :tempo, :interval, :interval=, :join
  
    def initialize(*args, &event)
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
        initialize_sync(options[:children], options[:sync_to])
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
        @destinations.each { |d| d.send(:tick) if d.respond_to?(:tick) }
        yield
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
      @destinations.each { |dest| dest.start(:parent => self) }
      @source.start(options) if options[:parent].nil?
      @actions[:start].call unless @actions[:start].nil?
    end
    
    # this will stop tempo
    def stop(options = {})
      @destinations.each { |dest| dest.stop(:parent => self) }
      @source.stop(options) if options[:parent].nil?
      @actions[:stop].call unless @actions[:stop].nil?
      @start_time = nil
    end
    
    # seconds since start was called
    def time
      @start_time.nil? ? nil : (Time.now - @start_time).to_f
    end
    alias_method :time_since_start, :time
    
    # add a destination
    # accepts MIDISyncOutput or another Tempo object
    def add_destination(tempo)
      @destinations << tempo
      @start_time.nil? ? tempo.stop : tempo.start
    end
    alias_method :<<, :add_destination
    alias_method :sync_from, :add_destination
    
    # sync to another Tempo object
    def sync_to(tempo)
      tempo.add_destination(self)
    end
    
    # remove all sync connections to <em>tempo</em>
    def unsync(tempo)
      @destinations.delete(tempo)
      tempo.unsync(self)
    end
    
    protected
    
    def tick
      @actions[:tick].call
    end
    
    private
    
    def initialize_sync(children, sync_to)
      children = [children].flatten.compact
      sync_to = [sync_to].flatten.compact
      children.each { |t| add_destination(t) }
      sync_to.each { |t| sync_to(t) }
    end
        
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