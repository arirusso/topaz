module Topaz
  
  class Tempo
    
    extend Forwardable
        
    include MIDIMessage # namespace
    
    attr_accessor :inputs,
                  :outputs,
                  :scheduler
                  
    def_delegators :scheduler, :at
    
    def initialize(tempo, options = {})
      @inputs = { :midi => (options[:midi_inputs] || [options[:midi_input]]).compact }
      @outputs = { :midi => (options[:midi_outputs] || [options[:midi_output]]).compact }
             
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo})
      
      initialize_midi
    end
    
    def start
      output_midi { |o| o.puts(SystemCommon["Start"].to_bytes) }
      @scheduler.run
      @scheduler.join
    end

    def stop
      output_midi { |o| o.puts(SystemCommon["Stop"].to_bytes) }
      @scheduler.stop
    end
        
    private
    
    def output_midi(&task)
      @outputs[:midi].each do |output|
        task.call(output)
      end      
    end
    
    def initialize_midi
      @scheduler.at(16) do
        output_midi { |o| o.puts(SystemCommon["Continue"].to_bytes) }       
      end
    end
        
  end  
  
end