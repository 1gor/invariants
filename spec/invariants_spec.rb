# frozen_string_literal: true

RSpec.describe Invariants do
  it "has a version number" do
    expect(Invariants::VERSION).not_to be nil
  end

  let(:klass) {
    Class.new do
      include Invariants

      def initialize(score = 0, list = [])
        @score = score
        @list = list
      end

      attr_reader :score, :active

      def initialize(score = 2, active = true)
        @score = score
        @active = active
      end

      invariant :active do |num|
        raise "Cannot decrement non-active score_keeper" unless @active
      end

      invariant :not_negative do |num|
        raise "Cannot make score less than 0" if @score - num < 0
      end

      def decrement(num)
        enforce_invariants(num, :not_negative, :active)
        @score -= num
      end
    end
  }
  let(:obj) { klass.new(2, true) }

  it "raises error when invariant enforcement fails" do
    expect do
      obj.decrement(3)
    end.to raise_error(RuntimeError, "Cannot make score less than 0")
  end

  it "raises no error if invariant enforcement passes" do
    expect do
      obj.decrement(1)
    end.not_to raise_error
  end

  it "can handle multiple invariants" do
    obj.instance_variable_set(:@active, false)
    expect do
      obj.decrement(1)
    end.to raise_error(RuntimeError, "Cannot decrement non-active score_keeper")
  end
end
