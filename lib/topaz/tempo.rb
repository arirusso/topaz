module Topaz
  
  # main tempo class
  class Tempo
    
    extend Forwardable
    
    attr_reader :source
    
    def_delegators :source, :tempo
  
    def initialize(*a, &event)
      @action = { :on_tick => event }
      @source = case a.first
        when Numeric then InternalTempo.new(a.first, @action)
        when Hash then ExternalMIDITempo.new(a.first[:midi], @action)
      end
    end
    
    # this will effectively reinitialize, switching from internal to external midi or vice versa
    #
    # if switching to internal clock, the rate of the midi tempo will be maintained
    # by the internal generator
    #
    # if switching to external midi, the program will wait for a start or clock message
    # 
    def switch_source
      
    end
    
    # this will change the tempo
    #
    # be warned, in the case that external midi tempo is being used, this will switch to internal 
    # tempo at the desired rate
    #
    def tempo=(val)
      # if @source.respond_to?(:tempo=)
      # etc 
    end
    
    # this will start the generator
    #
    # in the case that external midi tempo is being used, this will wait for a start 
    # or clock message
    #
    def start(options = {})
      @source.start(options)
    end
    
    # this will stop everything
    def stop(options = {})
      @source.stop(options)
    end
    
  end
  
end