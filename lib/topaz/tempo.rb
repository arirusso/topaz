module Topaz
  
  class Tempo
    
    extend Forwardable
        
    include MIDIMessage # namespace
    include MIDIEye::Listener # module
    
    attr_accessor :inputs,
                  :outputs
                  
    def_delegators :@scheduler, :at                   
    def_delegator :@scheduler, :tempo, :rate
    def_delegator :@scheduler, :tempo=, :rate=
    
    listen_on :midi_inputs, :type => :unimidi
    
    midi_event :on_start, :when => Proc.new { |e| e[:message].name.eql?("Start") }
    midi_event :on_clock, :when => Proc.new { |e| e[:message].name.eql?("Clock") }
    midi_event :stop, :when => Proc.new { |e| e[:message].name.eql?("Stop") }  
    
    def initialize(tempo, options = {})
      @inputs = { :midi => (options[:midi_inputs] || [options[:midi_input]]).compact }
      @outputs = { :midi => (options[:midi_outputs] || [options[:midi_output]]).compact }
      
      @running = false             
      @scheduler = Gamelan::Scheduler.new({:tempo => tempo, :rate => 24, :granularity => 256})
      @tempo_calculator = TempoCalculator.new

      initialize_midi_listener            
      initialize_midi
    end
    
    def on_start(*a)
      unless @running
        @exit_background_requested = true
        output_midi { |o| o.puts(SystemRealtime["Start"].new.to_a) }
      end
    end
    
    def start(*a)
      unless @running
        @running = true
        @scheduler.run     
        @scheduler.join
      end      
    end
    alias_method :on_exit_background_thread, :start
    
    def stop(*a)
      if @running
        output_midi { |o| o.puts(SystemRealtime["Stop"].new.to_a) }
        @scheduler.stop
        @running = false
        close
      end
    end
    
    def on_clock(event)
      @tempo_calculator.process(event[:timestamp])
    end
    
    def wait_for_midi_start(options = {})
      run(options)
    end
    
    def midi_inputs
      @inputs[:midi]
    end
        
    private
    
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
      (1..2048).each do |i|
        @scheduler.at(i/24.0) do
          output_midi do |output|
            output.puts(SystemRealtime["Clock"].new.to_a)
          end                 
        end
        @scheduler.at(i/24.0) do 
          poll
          trigger_queued_events
        end                    
        @scheduler.at(i) do                    
          adjust_tempo unless @tempo_calculator.nil?
        end
      end
    end
        
  end  
  
end