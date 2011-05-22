#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'topaz'

# a fake little sequencer for demonstration
class Sequencer
  
  def step
    @i ||= 0
    p "step #{@i+=1}"
  end
  
end

seq = Sequencer.new
@tempo = Topaz::Tempo.new(132) { seq.step }
@tempo.start
