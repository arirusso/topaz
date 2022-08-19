# frozen_string_literal: true

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift "#{dir}/../lib"

require 'rspec'
require 'topaz'

# Updates so that RSpec's instance_double returns true when compared
# to the class it's based on using is_a? kind_of? instance_of? and ===
# based on https://gist.github.com/thefotios/23912e524f585d855606dbec713df388
module VerifiedDoubleExtensions
  def verified_double(klass, *args)
    instance_double(klass, *args).tap do |dbl|
      double_equivalence(klass, dbl)
      double_class_comparison(klass, dbl)
    end
  end

  private

  CLASS_EQUIVALENCE_FUNCTIONS = %i[is_a? kind_of? instance_of?].freeze

  def double_equivalence(klass, dbl)
    CLASS_EQUIVALENCE_FUNCTIONS.each do |fn|
      allow(dbl).to receive(fn) do |*fn_args|
        klass.allocate.send(fn, *fn_args)
      end
    end
  end

  def double_class_comparison(klass, dbl)
    allow(klass).to receive(:===).and_call_original # do the normal thing by default
    allow(klass).to receive(:===).with(dbl).and_return true
  end
end

RSpec.configure do |c|
  c.include VerifiedDoubleExtensions
end
