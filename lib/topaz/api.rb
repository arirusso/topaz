module Topaz

  module API

    def self.included(base)
      base.send(:extend, Forwardable)
      base.send(:def_delegators, :source, :interval, :interval=, :join, 
                :pause, :pause?, :paused?, :running?, :tempo, :toggle_pause, :unpause)
      base.send(:alias_method :time_since_start, :time)
    end
    
  end
end
