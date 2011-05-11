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
      
      @observers = []             
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo})
      
      @input_observers ||= []
      @input_observers << MIDIInputObserver.new(@inputs[:midi]) unless @inputs[:midi].nil?      
      
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
    
    #def wait_for_start
    #  @midi_start_listener = Thread.fork do
    #    while (poll_inputs).nil?
    #      sleep(0.05)
    #    end
    #    start
    #  end      
    #end
    
    #def poll_inputs
    #  input_midi do |input|
    #    
    #  end      
    #end

    def input_midi(&task)
      @inputs[:midi].each do |input|
        task.call(input)
      end      
    end

    
    def output_midi(&task)
      @outputs[:midi].each do |output|
        task.call(output)
      end      
    end
    
    def adjust_tempo
      @input_observers.each do |obs|
        obs.detect_tempo
        tempo = obs.tempo unless obs.tempo.nil?
      end
    end
    
    def initialize_midi
      (1..128).each do |i|
        @scheduler.at(i) do
          unless @input_observers.empty?
            input_midi do |input|
              adjust_tempo
            end
          end
          output_midi do |output| 
            output.puts(SystemRealtime["Continue"].new.to_a)
          end       
        end
      end
    end
        
  end  
  
end