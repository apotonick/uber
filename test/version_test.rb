require 'test_helper'


class VersionTest < MiniTest::Spec
    subject { Uber::Version.new("1.2.3") } # Rails version

    it { subject.~("1.0").must_equal false }
    it { subject.~("1.1").must_equal false }
    it { subject.~("1.2").must_equal true }
    it { subject.~("1.3").must_equal false }
    it { subject.~("2.2").must_equal false }
    it { subject.~("1.0", "1.1").must_equal false }
    it { subject.~("1.0", "1.1", "1.2").must_equal true }
    it { subject.~("1.2", "1.3").must_equal true }

    it { (subject >= "1.2").must_equal true }
    it { (subject >= "1.1").must_equal true }
    it { (subject >= "1.3").must_equal false }
    it { (subject >= "2.1").must_equal false }
end