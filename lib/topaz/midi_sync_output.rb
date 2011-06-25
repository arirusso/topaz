#!/usr/bin/env ruby
module Topaz
  
  # send sync messages via MIDI
  class MIDISyncOutput
     
    def initialize(output, options = {})
      @output = output
    end
    
    # send a start message
    def start
      @output.puts(MIDIMessage::SystemRealtime["Start"].new.to_a)
    end

    # send a stop message
    def stop
      @output.puts(MIDIMessage::SystemRealtime["Stop"].new.to_a)
    end
        
    # send a clock message
    def tick
      @output.puts(MIDIMessage::SystemRealtime["Clock"].new.to_a)
    end
    
  end
  
end