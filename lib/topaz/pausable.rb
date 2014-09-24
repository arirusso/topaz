module Topaz

  # Pause functionality
  module Pausable

    # Pause the clock
    # @return [Boolean]
    def pause
      @pause = true
    end

    # Unpause the clock
    # @return [Boolean]
    def unpause
      @pause = false
    end

    # Is this clock paused?
    # @return [Boolean]
    def paused?
      @pause
    end
    alias_method :pause?, :paused?

    # Toggle pausing the clock
    # @return [Boolean]
    def toggle_pause
      @pause = !@pause      
    end

  end
end
