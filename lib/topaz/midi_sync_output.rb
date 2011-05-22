module Topaz
  
  # send sync messages via MIDI
  class MIDISyncOutput
     
    def initialize(output, options = {})
      @output = output
    end
    
    def on_start
      @output.puts(MIDIMessage::SystemRealtime["Start"].new.to_a)
    end

    def on_stop
      @output.puts(MIDIMessage::SystemRealtime["Stop"].new.to_a)
    end
        
    def on_tick
      @output.puts(MIDIMessage::SystemRealtime["Clock"].new.to_a)
    end
    
  end
  
end