module Topaz
  
  # Send clock messages via MIDI
  class MIDISyncOutput
    
    attr_reader :output
     
    def initialize(output)
      @output = output
    end
    
    # Send a start message
    def start(*a)
      start = MIDIMessage::SystemRealtime["Start"].new.to_a
      @output.puts(start)
    end

    # Send a stop message
    def stop(*a)
      stop = MIDIMessage::SystemRealtime["Stop"].new.to_a
      @output.puts(stop)
    end
        
    # Send a clock tick message
    def clock(*a)
      clock = MIDIMessage::SystemRealtime["Clock"].new.to_a
      @output.puts(clock)
    end
    
  end
  
end
