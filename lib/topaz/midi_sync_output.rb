#!/usr/bin/env ruby
module Topaz
  
  # send sync messages via MIDI
  class MIDISyncOutput
    
    attr_reader :output
     
    def initialize(output, options = {})
      @output = output
    end
    
    # send a start message
    def start(*a)
      @output.puts(MIDIMessage::SystemRealtime["Start"].new.to_a)
    end

    # send a stop message
    def stop(*a)
      @output.puts(MIDIMessage::SystemRealtime["Stop"].new.to_a)
    end
        
    # send a clock message
    def midi_clock(*a)
      @output.puts(MIDIMessage::SystemRealtime["Clock"].new.to_a)
    end
    
  end
  
end