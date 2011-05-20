module Topaz

  class InternalTempo
    
    def initialize(tempo, &handle_step)
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo})
      @scheduler.at(1, &handle_step)
    end
    
    def start
      @scheduler.run
      @scheduler.join
    end
    
  end
  
end
