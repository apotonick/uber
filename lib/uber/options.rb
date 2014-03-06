module Uber
# TODO: check performance. apply Options pattern to versioner, etc.
  # TODO: save iteration where we look for lambda and flag that right away.
  class Options < Hash
    class Option
      def initialize(value, options={})
        @value = value || true
        @options = options
      end

      def evaluate(context, *args)
        return true if @value.is_a?(TrueClass)

        evaluate_for(context, *args)
      end

      def dynamic?
        @options[:instance_method] || @value.kind_of?(Proc)
      end

    private
      def evaluate_for(context, *args)
        return proc!(context, *args) unless @value.kind_of?(Proc)
        @value.call(context, *args) # TODO: change to context.instance_exec and deprecate first argument.
      end

      def proc!(context, *args)
        return context.send(@value, *args) if @options[:instance_method]
        @value
      end
    end


    def initialize(options)
      @is_dynamic = false

      options.each do |k,v|
        self[k] = option = Option.new(v)
        @is_dynamic ||= option.dynamic?
      end
    end

    #   1.100000   0.060000   1.160000 (  1.159762) original
    #   0.120000   0.010000   0.130000 (  0.135803) return self
    #   0.930000   0.060000   0.990000 (  0.997095) without v.evaluate

    def evaluate(context, *args)
      #return self
      #puts "we're called ++++++++++++++++++++++++++++++++++++ #{inspect}"
      {}.tap do |evaluated|
        each do |k,v|
          evaluated[k] = v.evaluate(context, *args)
        end
      end
    end

  private
    def dynamic?
      @is_dynamic
    end
  end
end