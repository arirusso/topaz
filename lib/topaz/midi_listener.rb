module Topaz
  
  class MIDISource
    
    attr_reader :device, :pointer
    
    Parser = Nibbler.new
    
    def initialize(input)      
      @pointer = 0      
      @device = input      
    end
    
    def poll(observer, events)
      msgs = @device.buffer.slice(@pointer, @device.buffer.length - @pointer)
      msgs.each do |raw_msg|
        objs = [Parser.parse(raw_msg[:data], :timestamp => raw_msg[:timestamp])].flatten.compact
        objs.each do |batch|
          [batch[:messages]].flatten.each do |m|
            msg = { :message => m, :timestamp => batch[:timestamp] }
            events.each do |action|
              condition = action[:condition].call(msg) unless action[:condition].nil?
              observer.send(action[:method], msg) if condition
            end
          end 
        end
      end
      @pointer = @device.buffer.length      
    end
            
  end
  
  module MIDIListener
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def init_observer
      @sources = [self.send(self.class.sources)].flatten.map { |src| MIDISource.new(src) }
    end
    
    def observe_midi
      @sources.each { |i| i.poll(self, self.class.midi_events) }
    end
    
    module ClassMethods
      
      attr_reader :midi_events, :sources
      
      def midi_event(method, options = {})
        @midi_events ||= []
        @midi_events << { :method => method, :condition => options[:when] }
      end
      
      def listen_on(sources)
        @sources = sources
      end
      
    end
                
  end  
  
end