module Topaz
  
  class Tempo
    
    extend Forwardable
        
    include MIDIMessage # namespace
    
    attr_accessor :inputs,
                  :outputs,
                  :scheduler
                  
    def_delegators :scheduler, :at                   
    def_delegator :scheduler, :tempo, :rate
    def_delegator :scheduler, :tempo=, :rate=
    
    def initialize(tempo, options = {})
      @inputs = { :midi => (options[:midi_inputs] || [options[:midi_input]]).compact }
      @outputs = { :midi => (options[:midi_outputs] || [options[:midi_output]]).compact }
             
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo})
      
      initialize_midi
    end
    
    def start
      output_midi { |o| o.puts(SystemRealtime["Start"].new.to_a) }
      @scheduler.run
      @scheduler.join
    end

    def stop
      output_midi { |o| o.puts(SystemRealtime["Stop"].new.to_a) }
      @scheduler.stop
    end
        
    private
    
    def output_midi(&task)
      @outputs[:midi].each do |output|
        task.call(output)
      end      
    end
    
    def initialize_midi
      (1..16).each do |i|
      @scheduler.at(i) do
        output_midi { |o| o.puts(SystemRealtime["Continue"].new.to_a) }       
      end
      end
    end
        
  end  
  
end