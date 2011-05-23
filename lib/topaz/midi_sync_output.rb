#!/usr/bin/env ruby
module Topaz
  
  # send sync messages via MIDI
  class MIDISyncOutput
     
    def initialize(output, options = {})
      @output = output
    end
    
    # send a start message
    def on_start
      @output.puts(MIDIMessage::SystemRealtime["Start"].new.to_a)
    end

    # send a stop message
    def on_stop
      @output.puts(MIDIMessage::SystemRealtime["Stop"].new.to_a)
    end
        
    # send a clock message
    def on_tick
      @output.puts(MIDIMessage::SystemRealtime["Clock"].new.to_a)
    end
    
  end
  
end