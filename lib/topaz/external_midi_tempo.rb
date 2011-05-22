module Topaz
  
  # trigger an event based on received midi clock messages
  class ExternalMIDITempo
   
    extend Forwardable 
    
    attr_reader :clock
    
    def_delegators :clock, :start, :stop
  
    def initialize(input, action, options = {})
      self.interval = options[:interval] || 4
      @action = action
      @tempo_calculator = TempoCalculator.new
      @clock = MIDIEye::Listener.new(input)
      
      initialize_clock 
    end
    
    # this will return a calculated tempo
    def tempo
      @tempo_calculator.find_tempo
    end
    
    def interval=(val)
      per_qn = val / 4
      @per_tick = 24 / per_qn
    end
    
    private
    
    def initialize_clock
      @counter = 0
      @clock.listen_for(:name => "Clock") do |msg|
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