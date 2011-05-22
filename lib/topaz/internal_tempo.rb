module Topaz

  class InternalTempo < Gamelan::Timer
    
    def initialize(tempo, action, options = {})
      self.interval = options[:interval] || 4
      @action = action
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
      unless @last.eql?((@phase * @interval).to_i)
        @action[:on_tick].call
        @last = (@phase * @interval).to_i
      end      
    end
     
  end
  
end
