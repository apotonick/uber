module Uber
# TODO: check performance. apply Options pattern to versioner, etc.
  # TODO: save iteration where we look for lambda and flag that right away.
  class Options < Hash
    class Option
      def initialize(proc, options={})
        @proc = proc || true
        @options = options
      end

      def evaluate(context, *args)
        return true if @proc.is_a?(TrueClass)

        evaluate_for(context, *args)
      end


    private
      def dynamic?
        @options[:instance_method] || @proc.kind_of?(Proc)
      end


      def evaluate_for(context, *args)
        return proc!(context, *args) unless @proc.kind_of?(Proc)
        @proc.call(context, *args) # TODO: change to context.instance_exec and deprecate first argument.
      end

      def proc!(context, *args)
        return context.send(@proc, *args) if @options[:instance_method]
        @proc
      end
    end

    def initialize(options)
      options.each do |k,v|
        self[k] = Option.new(v)
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
  end
end