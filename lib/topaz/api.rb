module Topaz

  # Convenience shortcuts for the clock
  module API

    def self.included(base)
      base.send(:extend, Forwardable)
      base.send(:def_delegators, :source, :interval, :interval=, :join, 
                :pause, :pause?, :paused?, :running?, :tempo, :toggle_pause, :unpause)
    end

    # Alias for Clock#time
    # @return [Time]
    def time_since_start
      time
    end
    
  end
end
