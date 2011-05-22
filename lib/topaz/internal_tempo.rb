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
    
    def start(options = {})
      run
      join unless options[:background]
    end
    
    def interval=(val)
      @interval = val / 4
    end
    
    protected
    
    # Run all ready tasks.
    def dispatch
      unless @last_sync.eql?((@phase * 24).to_i) 
        @action[:destinations].each { |dest| dest.on_tick }        
        @last_sync = (@phase * 24).to_i
        p 'hi'
      end
      unless @last.eql?((@phase * @interval).to_i)
        @action[:on_tick].call
        @last = (@phase * @interval).to_i
      end      
    end
     
  end
  
end
