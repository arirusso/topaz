module Topaz

  class InternalTempo < Gamelan::Timer
    
    def initialize(tempo, action, options = {})
      @action = action
      super({:tempo => tempo})
    end
    
    def start(options = {})
      run
      join unless options[:background]
    end
    
    protected
    
    # Run all ready tasks.
    def dispatch
      unless @last.eql?(@phase.to_i)
        @action[:on_tick].call(@tempo) 
        @last = @phase.to_i
      end      
    end
     
  end
  
end
