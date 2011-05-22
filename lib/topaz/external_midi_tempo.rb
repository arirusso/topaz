module Topaz
  
  # trigger an event based on received midi clock messages
  class ExternalMIDITempo
    
    extend Forwardable 
    
    attr_reader :clock
    
    def_delegators :clock, :start, :stop
  
    def initialize(input, action, options = {})
      @action = action
      @tempo_calculator = TempoCalculator.new
      @clock = MIDIEye::Listener.new(input)
      initialize_clock 
    end
    
    # this will return a calculated tempo
    def tempo
      @tempo_calculator.find_tempo
    end
    
    private
    
    def initialize_clock
      @counter = 0
      @clock.listen_for(:name => "Clock") do |msg|
        @tempo_calculator.timestamps << msg[:timestamp]
        if @counter.eql?(23) 
          @action[:on_tick].call
          @counter = 0 
        else
          @counter += 1
        end
      end
    end
    
  end
  
end