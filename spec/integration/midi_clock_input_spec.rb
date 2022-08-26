# frozen_string_literal: true

require 'integration/helper'

describe Topaz::MIDIClockInput do
  let(:input) { double }
  let(:event) { double }
  let(:clock) { Topaz::MIDIClockInput.new(input, event: event) }

  describe '#thru' do
    it 'fires clock event' do
      expect(event).to receive(:do_clock).exactly(:once)
      expect(clock.send(:thru)).to_not be_nil
    end
  end

  describe '#tick' do
    it 'fires tick event' do
      expect(event).to receive(:do_tick).exactly(:once)
      expect(clock.send(:tick)).to_not be_nil
    end
  end

  describe '#tick?' do
    context 'when counter has reached tick threshold' do
      it 'ticks' do
        expect(clock.interval).to eq(4)
        23.times do
          expect(clock.send(:tick?)).to eq(false)
          clock.send(:advance)
        end
        expect(clock.send(:tick?)).to_not be_nil
        clock.send(:advance)
      end
    end
  end
end
