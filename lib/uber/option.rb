require "uber/callable"

module Uber
  class Option
    def self.[](value, options={}) # TODO: instance_exec: true
      case value
      when Proc
        return ->(context, *args) { context.instance_exec(*args, &value) } if options[:instance_exec]
        value
      when Uber::Callable
        value
      when Symbol
        ->(context, *args) { context.send(value, *args) }
      else
        ->(*) { value }
      end
    end
  end
end
