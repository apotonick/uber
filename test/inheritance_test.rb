require 'test_helper'
require 'uber/inheritable_included'

module InheritIncludedTo
  def self.call(base)
    base.class_eval do
      puts "addin included to #{base}"
      def self.included(b) #
        CODE_BLOCK.call(b)

        InheritIncludedTo.call(b)
      end
    end
  end
end

class InheritanceTest < MiniTest::Spec
  module Feature
    #extend Uber::InheritedIncluded

    ::CODE_BLOCK = lambda { |base| base.class_eval { extend ClassMethods } } # i want that to be executed at every include


    def self.included(base) #
      CODE_BLOCK.call(base)
      InheritIncludedTo.call(base)
    end

    module ClassMethods
      def feature; end
    end
  end

  module Extension
    include Feature

    # TODO: test overriding ::included
  end

  module Client
    include Extension
  end

  it { Extension.must_respond_to :feature }
  it { Client.must_respond_to :feature }
end
