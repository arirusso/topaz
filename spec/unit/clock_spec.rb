# frozen_string_literal: true

require 'unit/helper'

describe Topaz::Clock do
  let(:count_to) { 5 }
  let(:tempo) { Topaz::Clock.new(120) { @counter += 1 } }
  before do
    @counter = 0
  end

  describe '#interval=' do
    it 'changes interval' do
      expect(tempo.interval).to eq(4)
      tempo.interval = 8
      expect(tempo.interval).to eq(8)
    end
  end

  describe '#tick' do
    it 'changes tick action' do
      @is_running = false
      tempo.event.tick { @is_running = true }
      expect(@is_running).to eq(false)

      tempo.start(background: true)
      loop until tempo.running?
      loop until @is_running
    end
  end

  describe '#stop' do
    before do
      tempo.trigger.stop { @counter.eql?(count_to) }
    end

    it 'stops' do
      tempo.start
      expect(@counter).to eq(count_to)
    end
  end
end
