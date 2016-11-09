require "uber/option"

module Uber
  module Builder
    def self.included(base)
      base.extend DSL
      base.extend Build
    end

    # Computes the concrete target class.
    class Constant
      def self.call(builders, context, *args)
        builders.each do |block|
          klass = block.(context, *args) and return klass # Uber::Value#call()
        end

        context
      end
    end

    module DSL
      def builders
        @builders ||= []
      end

      def builds(proc=nil, &block)
        builders << Uber::Option[proc || block, instance_exec: true]
      end
    end

    module Build
      # Call this from your class to compute the concrete target class.
      def build!(context, *args)
        Constant.(builders, context, *args)
      end
    end
  end
end
