require 'test_helper'
require 'uber/options'

class UberOptionTest < MiniTest::Spec
  Option = Uber::Options::Option

  describe "#dynamic?" do
    it { Option.new(1).dynamic?.must_equal false }
    it { Option.new(true).dynamic?.must_equal false }
    it { Option.new(:loud).dynamic?.must_equal false }

    it { Option.new(lambda {}).dynamic?.must_equal true }
    it { Option.new(Proc.new{}).dynamic?.must_equal true }
    it { Option.new(:method, :instance_method => true).dynamic?.must_equal true }
  end



#   it "speed" do
#     require "benchmark"

#     options = 1000000.times.collect do
#       Uber::Options.new(expires: false)
#     end

#     time = Benchmark.measure do
#       options.each do |opt|
#         opt.evaluate(nil)
#       end
#     end

#     puts "good results"
#     puts time
#   end
end

class UberOptionsTest < MiniTest::Spec
  Options = Uber::Options

  describe "#dynamic?" do
    it { Options.new(:volume =>1, :style => "Punkrock").send(:dynamic?).must_equal false }
  end
end