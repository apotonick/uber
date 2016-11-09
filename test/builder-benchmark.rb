require "test_helper"
require "uber/builder"
require "benchmark/ips"

builders = [
  ->(context, options) { return Module if options[:module] },
  ->(context, options) { return Class  if options[:class] }
]

c = Uber::Builder::Constant.new(Object, self, builders)
e = Uber::Builder::Evaluate.new(Object, builders)

Benchmark.ips do |x|
  x.report(:constant) { c.({}) }
  x.report(:Evaluate) { e.(self, {}) }

end
