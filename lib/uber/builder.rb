require "uber/options"

module Uber
  # When included, allows to add builder on the class level.
  #
  #   class Operation
  #     include Uber::Builder
  #
  #     builds do |params|
  #       SignedIn if params[:current_user]
  #     end
  #
  #     class SignedIn
  #     end
  #
  # The class then has to call the builder to compute a class name using the build blocks you defined.
  #
  #     def self.build(params)
  #       class_builder.call(params).
  #       new(params)
  #     end
  module Builder
    def self.included(base)
      base.extend ClassMethods
    end

    # Computes the concrete target class.
    class Constant
      def initialize(constant, context, builders=constant.builders)
        @constant, @context, @builders = constant, context, builders
      end

      def call(*args)
        @builders.each do |block|
          klass = block.(@context, *args) and return klass # Uber::Value#call()
        end
        @constant
      end
    end

    module ClassMethods
      def builders
        @builders ||= []
      end

      # Adds a builder to the cell class. Builders are used in #cell to find out the concrete
      # class for rendering. This is helpful if you frequently want to render subclasses according
      # to different circumstances (e.g. login situations) and you don't want to place these deciders in
      # your view code.
      #
      # Passes the model and options from #cell into the block.
      #
      # Multiple build blocks are ORed, if no builder matches the building cell is used.
      #
      # Example:
      #
      # Consider two different user box cells in your app.
      #
      #   class AuthorizedUserBox < UserInfoBox
      #   end
      #
      #   class AdminUserBox < UserInfoBox
      #   end
      #
      # Now you don't want to have deciders all over your views - use a declarative builder.
      #
      #   UserInfoBox.build do |model, options|
      #     AuthorizedUserBox if options[:is_signed_in]
      #     AdminUserBox if model.admin?
      #   end
      #
      # In your view #cell will instantiate the right class for you now.
      def builds(proc=nil, &block)
        builders << Uber::Options::Value.new(proc.nil? ? block : proc) # TODO: provide that in Uber::O:Value.
      end

      # Call this from your classes' own ::build method to compute the concrete target class.
      # The class_builder is cached, you can't change the context once it's set.
      def class_builder(context=nil)
        @class_builder ||= Constant.new(self, context, self.builders)
      end
    end # ClassMethods

    DSL = ClassMethods
  end
end
