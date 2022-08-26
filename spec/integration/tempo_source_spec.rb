# frozen_string_literal: true

require 'integration/helper'

describe Topaz::TempoSource do
  describe '#initialize' do
    context 'when a midi input clock is given' do
      let(:input) { verified_double(UniMIDI::Input) }

      it 'constructs a midi input clock' do
        result = Topaz::TempoSource.new(input)
        expect(result).to_not be_nil
        expect(result).to be_a(Topaz::MIDIClockInput)
      end
    end
  end
end
