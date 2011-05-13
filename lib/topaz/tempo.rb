module Topaz
  
  class Tempo
    
    extend Forwardable
        
    include MIDIMessage # namespace
    include MIDIListener # module
    
    attr_accessor :inputs,
                  :outputs
                  
    def_delegators :@scheduler, :at                   
    def_delegator :@scheduler, :tempo, :rate
    def_delegator :@scheduler, :tempo=, :rate=
    
    listen_on :midi_inputs
    
    #midi_event :start, :when => Proc.new { |e| 250.eql?(e[:message].to_a.first) }
    midi_event :on_clock, :when => Proc.new { |e| 248.eql?(e[:message].to_a.first) }
    midi_event :stop, :when => Proc.new { |e| 252.eql?(e[:message].to_a.first) }  
    
    def initialize(tempo, options = {})
      @inputs = { :midi => (options[:midi_inputs] || [options[:midi_input]]).compact }
      @outputs = { :midi => (options[:midi_outputs] || [options[:midi_output]]).compact }
      
      @running = false             
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo, :rate => 24, :granularity => 100})
      @tempo_calculator = TempoCalculator.new

      init_observer            
      initialize_midi
    end
    
    def start(*a)
      if !@running
        output_midi { |o| o.puts(SystemRealtime["Start"].new.to_a) }
        @scheduler.run
        @scheduler.join
        @running = true
      end
    end

    def stop(*a)
      if @running
        output_midi { |o| o.puts(SystemRealtime["Stop"].new.to_a) }
        @scheduler.stop
        @running = false
      end
    end
    
    def wait_for_midi_start
      
    end
    
    def midi_inputs
      @inputs[:midi]
    end
        
    private
    
    def on_clock(event)
      @tempo_calculator.process(event[:timestamp])
    end
    
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
      tempo= @tempo_calculator.tempo
    end
    
    def initialize_midi
      (1..128).each do |i|
        @scheduler.at(i/24.0) do
          output_midi do |output|
            output.puts(SystemRealtime["Continue"].new.to_a)
          end                 
        end
        @scheduler.at(i/2.0) do
          observe_midi
        end
        @scheduler.at(i) do                    
          adjust_tempo unless @tempo_calculator.nil?
        end
      end
    end
        
  end  
  
end