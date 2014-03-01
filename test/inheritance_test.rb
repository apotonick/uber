require 'test_helper'
require 'uber/inheritable_included'

class InheritanceTest < MiniTest::Spec
  module Feature
    #extend Uber::InheritedIncluded

    def self.included(base)
      super # from uber?
      puts "selber"
      base.class_eval { extend ClassMethods }
    end

    module ClassMethods
      def feature; end
    end

  end

  module Extension
    include Feature

    def self.included(base)
puts base
      #base.class_eval do
        Feature.included(base)
      #end
    end

    # TODO: test overriding ::included
  end

  module Client
    include Extension
  end

  it { Extension.must_respond_to :feature }
  it { Client.must_respond_to :feature }
end
