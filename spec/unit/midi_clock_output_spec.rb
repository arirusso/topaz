# frozen_string_literal: true

require 'unit/helper'

describe Topaz::MIDIClockOutput do
  let(:output) { double }
  let(:clock) { Topaz::MIDIClockOutput.new(device: output) }

  describe '#do_start' do
    it 'emits start message' do
      expect(output).to receive(:puts).exactly(:once).with(250)
      result = clock.do_start
      expect(result).to_not be_nil
    end
  end

  describe '#do_stop' do
    it 'emits stop message' do
      expect(output).to receive(:puts).exactly(:once).with(252)
      result = clock.do_stop
      expect(result).to_not be_nil
    end
  end

  describe '#do_clock' do
    it 'emits clock message' do
      expect(output).to receive(:puts).exactly(:once).with(248)
      result = clock.do_clock
      expect(result).to_not be_nil
    end
  end
end
