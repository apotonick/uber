require 'test_helper'
require 'uber/options'

class UberOptionTest < MiniTest::Spec
  Value = Uber::Options::Value

  describe "#dynamic?" do
    it { Value.new(1).dynamic?.must_equal false }
    it { Value.new(true).dynamic?.must_equal false }
    it { Value.new(:loud).dynamic?.must_equal false }

    it { Value.new(lambda {}).dynamic?.must_equal true }
    it { Value.new(Proc.new{}).dynamic?.must_equal true }
    it { Value.new(:method, :instance_method => true).dynamic?.must_equal true }
  end



  # it "speed" do
  #   require "benchmark"

  #   options = 1000000.times.collect do
  #     Uber::Options.new(expires: false)
  #   end

  #   time = Benchmark.measure do
  #     options.each do |opt|
  #       opt.evaluate(nil)
  #     end
  #   end

  #   puts "good results"
  #   puts time
  # end
end

class UberOptionsTest < MiniTest::Spec
  Options = Uber::Options

  let (:dynamic) { Options.new(:volume =>1, :style => "Punkrock", :track => Proc.new { |i| i.to_s }) }

  describe "#dynamic?" do
    it { Options.new(:volume =>1, :style => "Punkrock").send(:dynamic?).must_equal false }
    it { Options.new(:style => Proc.new{}, :volume =>1).send(:dynamic?).must_equal true }
  end

  describe "#evaluate" do

    it { dynamic.evaluate(999).must_equal({:volume =>1, :style => "Punkrock", :track => "999"}) }

    describe "static" do
      let (:static) { Options.new(:volume =>1, :style => "Punkrock") }

      it { static.evaluate(nil).must_equal({:volume =>1, :style => "Punkrock"}) }

      it "doesn't evaluate internally" do
        static.instance_eval do
          def evaluate_for(*)
            raise "i shouldn't be called!"
          end
        end
        static.evaluate(nil).must_equal({:volume =>1, :style => "Punkrock"})
      end
    end
  end

  describe "#[]" do
    it { dynamic.eval(:volume, 999).must_equal 1 }
    it { dynamic.eval(:style, 999).must_equal "Punkrock" }
    it { dynamic.eval(:track, 999).must_equal "999" }
  end
end