module Uber
  class Options < Hash
    def initialize(options)
      @static = options

      options.each do |k,v|
        self[k] = option = Value.new(v)
        @static = nil if option.dynamic?
      end
    end

    #   1.100000   0.060000   1.160000 (  1.159762) original
    #   0.120000   0.010000   0.130000 (  0.135803) return self
    #   0.930000   0.060000   0.990000 (  0.997095) without v.evaluate

    def evaluate(context, *args)
      return @static unless dynamic?

      evaluate_for(context, *args)
    end

    def eval(key, *args)
      self[key].evaluate(*args)
    end

  private
    def evaluate_for(context, *args)
      {}.tap do |evaluated|
        each do |k,v|
          evaluated[k] = v.evaluate(context, *args)
        end
      end
    end

    def dynamic?
      not @static
    end


    class Value # TODO: rename to Value.
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
  end
end