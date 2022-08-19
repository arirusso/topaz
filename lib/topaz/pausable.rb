# frozen_string_literal: true

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
    alias pause? paused?

    # Toggle pausing the clock
    # @return [Boolean]
    def toggle_pause
      @pause = !@pause
    end
  end
end
