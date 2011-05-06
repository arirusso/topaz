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
      
      schedule_midi_events
    end
    
    def start
      each_midi_output { |o| o.puts(SystemCommon["Start"].to_bytes) }
      @scheduler.run
      @scheduler.join
    end

    def stop
      each_midi_output { |o| o.puts(SystemCommon["Stop"].to_bytes) }
      @scheduler.stop
    end
        
    private
    
    def each_midi_output(&task)
      @outputs[:midi].each do |output|
        task.call(output)
      end      
    end
    
    def schedule_midi_events
      @scheduler.at(16) do
        each_midi_output { |o| o.puts(SystemCommon["Continue"].to_bytes) }       
      end
    end
        
  end  
  
end