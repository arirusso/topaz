module Topaz
  
  class Input
    
    attr_reader :device, :tempo
    attr_accessor :cache, :pointer
    
    def initialize(device)
      @nibbler = Nibbler.new
      @tempo = nil
      @device = device
      @cache = []
      @pointer = 0
    end

    def analyze
      msgs = @device.buffer.slice(@pointer, @device.buffer.length - @pointer)
      msgs.each do |msg|
        @cache += [@nibbler.parse(msg[:data], :timestamp => msg[:timestamp])].flatten.compact
      end
      @pointer = @device.buffer.length
      filter_cache
    end
        
    private    
    
    def filter_cache      
      @cache.delete_if { |m| ![248, 250, 251, 252].include?(m[:messages].to_a.first) }       
    end  
    
  end
  
  class MIDIInputObserver
    
    attr_reader :tempo
    
    def initialize(inputs)
      @tempo = nil
      @inputs ||= []
      @inputs = inputs.map { |i| Input.new(i) }
    end
    
    def <<(input)
      @inputs << input
    end 
    
    def detect_tempo
      @inputs.each do |input|
        input.analyze
        @tempo = input.tempo unless input.tempo.nil?
      end
    end
            
  end  
  
end