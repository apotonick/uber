require 'test_helper'
require 'uber/options'

class UberOptionsTest < MiniTest::Spec
  Option = Uber::Options::Option

  describe "#dynamic?" do
    it { Option.new({:volume => 1}).dynamic?.must_equal true }
    it { Option.new({:volume => true}).dynamic?.must_equal true }
    it { Option.new({:volume => :loud}).dynamic?.must_equal true }

    it { Option.new({:volume => lambda {}}).dynamic?.must_equal false }
    it { Option.new({:volume => Proc.new{}}).dynamic?.must_equal false }
    it { Option.new({:volume => :method}, :instance_method => true).dynamic?.must_equal false }
  end



  it "speed" do
    require "benchmark"

    options = 1000000.times.collect do
      Uber::Options.new(expires: false)
    end

    time = Benchmark.measure do
      options.each do |opt|
        opt.evaluate(nil)
      end
    end

    puts "good results"
    puts time
  end
end