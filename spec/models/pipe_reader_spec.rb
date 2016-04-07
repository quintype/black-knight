require 'rails_helper'

class PipeReaderToEnumerable
  include Enumerable

  def initialize(file)
    @file = file
  end

  def each
    PipeReader.new(@file).read(10) { |i| yield i }
  end
end

describe PipeReader do
  it "it yields a set of outputs" do
    r, w = IO.pipe
    thread = Thread.new do
      PipeReaderToEnumerable.new(r).to_a
    end

    w.write("foo")
    w.close

    expect(thread.value).to eq ["foo"]
  end

  it "collapses multiple subsequent reads together" do
    r, w = IO.pipe
    thread = Thread.new do
      PipeReaderToEnumerable.new(r).to_a
    end

    sleep(0.005)
    w.write("foo")
    sleep(0.005)
    w.write("bar")
    sleep(0.005)
    w.write("baz")
    w.close

    expect(thread.value).to eq ["foo", "barbaz"]
  end

  it "only yields once every 10ms" do
    r, w = IO.pipe
    thread = Thread.new do
      times = []
      PipeReader.new(r).read(10) { |i| times << DateTime.now.to_f }
      times
    end

    sleep(0.005)
    w.write("foo")
    sleep(0.005)
    w.write("bar")
    w.close

    first_yield, second_yield = thread.value
    assert(second_yield - first_yield > 0.01)
  end
end
