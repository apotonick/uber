require 'test_helper'

class InheritanceTest < MiniTest::Spec
  module Feature
    def self.included(base)
      base.class_eval { def feature; end }
    end
  end

  module Extension
    include Feature

    # TODO: test overriding ::included
  end

  module Client
    include Extension
  end

  it { Client.must_respond_to :feature }
end
