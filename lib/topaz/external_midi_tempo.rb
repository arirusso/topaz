module Topaz
  
  # fire an event based on received midi clock messages
  class ExternalMIDITempo
  
    def initialize(input, &handle_step)
      @clock = MIDIEye::Listener.new(input)
      @clock.listen_for(:name => "Clock", &handle_step)
    end
    
    # this will return a calculated tempo
    def tempo
      
    end
    
  end
  
end