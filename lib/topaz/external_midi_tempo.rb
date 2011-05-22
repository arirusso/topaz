module Topaz
  
  # fire an event based on received midi clock messages
  class ExternalMIDITempo
    
    extend Forwardable 
    
    attr_reader :clock
    
    def_delegators :clock, :start, :stop
  
    def initialize(input, action, options = {})
      @action = action
      @clock = MIDIEye::Listener.new(input)
      @clock.listen_for(:name => "Clock", &@action[:on_step])
    end
    
    # this will return a calculated tempo
    def tempo
      
    end
    
  end
  
end