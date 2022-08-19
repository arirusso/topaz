# frozen_string_literal: true

require 'unit/helper'

describe Topaz::Timer do
  let(:timer) { Topaz::Timer.new(120) }

  describe '#dispatch' do
    let(:event) { double }
    let(:timer) { Topaz::Timer.new(120, event: event) }

    it 'fires MIDI clock/tick events' do
      timer.send(:initialize_running_state)
      timer.instance_variable_set('@phase', 1.022728443145751953)

      expect(event).to receive(:do_clock).exactly(:once).and_return(true)
      expect(event).to receive(:do_tick).exactly(:once).and_return(true)
      timer.send(:dispatch)
    end
  end

  describe '#start' do
    it 'starts running' do
      expect(timer.phase).to be_nil
      timer.start(background: true)
      loop until timer.running?

      expect(timer.running?).to eq(true)
      expect(timer.phase).to_not be_nil
      expect(timer.phase).to_not eq(0.0)
    end
  end

  describe '#stop' do
    it 'stops running' do
      expect(timer.phase).to be_nil
      timer.start(background: true)
      loop until timer.running?
      expect(timer.running?).to eq(true)
      expect(timer.phase).to_not be_nil
      expect(timer.phase).to_not eq(0.0)

      timer.stop

      expect(timer.running?).to eq(false)
    end
  end

  describe '#interval=' do
    it 'changes interval' do
      expect(timer.interval).to eq(4)
      timer.interval = 8
      expect(timer.interval).to eq(8)
    end
  end
end
