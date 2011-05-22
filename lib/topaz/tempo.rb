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
    
    # this will change the tempo
    #
    # be warned, in the case that external midi tempo is being used, this will switch to internal 
    # tempo at the desired rate
    #
    def tempo=(val)
      if @source.respond_to?(:tempo=)
        @source.tempo = val
      else
        @source = InternalTempo.new(tempo, @action)
      end 
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