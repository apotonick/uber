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

    # Evaluates every element and returns a hash.  Accepts context and arbitrary arguments.
    def evaluate(context, *args)
      return @static unless dynamic?

      evaluate_for(context, *args)
    end

    # Evaluates a single value.
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
        @value, @options = value, options
      end

      def evaluate(context, *args)
        return @value unless dynamic?

        evaluate_for(context, *args)
      end

      def dynamic?
        instance_method? || callable?
      end

    private
      def evaluate_for(*args)
        return method!(*args) unless callable?
         # TODO: change to context.instance_exec and deprecate first argument.
         proc!(*args)
      end

      def method!(context, *args)
        context.send(@value, *args)
      end

      def proc!(context, *args)
        @value.call(context, *args)
      end

      def callable?
        @value.kind_of?(Proc)
      end

      def instance_method?
        @options[:instance_method] and @value.is_a?(Symbol)
      end
    end
  end
end