#!/usr/bin/env ruby
module Topaz

  class InternalTempo < Gamelan::Timer
    
    attr_accessor :action
    
    def initialize(tempo, options = {})
      @action = options[:action]
      self.interval = options[:interval] || 4 
      @destinations = options[:destinations]
      @last = 0
      @last_sync = 0
      super({:tempo => tempo})
    end

    # start the internal timer
    # pass :background => true to keep the timer in a background thread
    def start(options = {})
      @action[:on_start].call unless @action[:on_start].nil?
      run
      join unless options[:background]
    end
    
    # change the timer's click interval    
    def interval=(val)
      @interval = val / 4
    end
    
    # stop the timer
    def stop(*a)
      @action[:on_stop].call unless @action[:on_stop].nil?
      super
    end
    
    protected
    
    # Run all ready tasks.
    def dispatch
      # stuff to do on every tick      
      unless @last_sync.eql?((@phase * 24).to_i)
        # look for stop
        if !@action[:stop_when].nil? && @action[:stop_when].call
          stop
          return
        end 
        @action[:destinations].each { |dest| dest.on_tick }        
        @last_sync = (@phase * 24).to_i
      end
      # stuff to do on @interval
      unless @last.eql?((@phase * @interval).to_i)
        @action[:on_tick].call
        @last = (@phase * @interval).to_i
      end      
    end
     
  end
  
end
