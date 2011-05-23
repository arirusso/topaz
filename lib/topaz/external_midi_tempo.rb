#!/usr/bin/env ruby
module Topaz
  
  # trigger an event based on received midi clock messages
  class ExternalMIDITempo
   
    attr_accessor :action
    attr_reader :clock
  
    def initialize(input, options = {})
      @action = options[:action]
      self.interval = options[:interval] || 4
      @tempo_calculator = TempoCalculator.new
      @clock = MIDIEye::Listener.new(input)
      
      initialize_clock 
    end
    
    # this will return a calculated tempo
    def tempo
      @tempo_calculator.find_tempo
    end
    
    def start
      @action[:on_start].call unless @action[:on_start].nil?
      @clock.start
    end
    
    def stop
      @action[:on_stop].call unless @action[:on_stop].nil?
      @clock.start
    end
        
    #
    # change the clock interval
    # defaults to click once every 24 ticks or one quarter note which is the MIDI standard.
    # however, if you wish to fire the on_tick event twice as often 
    # (or once per 12 clicks), pass 8 
    #
    #   1 = whole note
    #   2 = half note
    #   4 = quarter note
    #   6 = dotted quarter
    #   8 = eighth note
    #  16 = sixteenth note
    #  etc
    #
    def interval=(val)
      per_qn = val / 4
      @per_tick = 24 / per_qn
    end
    
    private
    
    def initialize_clock
      @counter = 0
      @clock.listen_for(:name => "Clock") do |msg|
        if !@action[:stop_when].nil? && @action[:stop_when].call
          stop
          return
        end 
        @action[:destinations].each do |output|
          output.on_tick
        end        
        @tempo_calculator.timestamps << msg[:timestamp]
        if @counter.eql?(@per_tick)
          @action[:on_tick].call
          @counter = 0 
        else
          @counter += 1
        end
      end
    end
    
  end
  
end