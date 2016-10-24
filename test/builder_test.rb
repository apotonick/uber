require 'test_helper'
require "uber/builder"

class BuilderTest < MiniTest::Spec
  Evergreen = Struct.new(:title)
  Hit  = Struct.new(:title)

  class Song
    include Uber::Builder

    builds do |options|
      if options[:evergreen]
        Evergreen
      elsif options[:hit]
        Hit
      end
    end

    def self.build(options)
      class_builder.call(options).new
    end
  end

  # building class if no block matches
  it { Song.build({}).must_be_instance_of Song }

  it { Song.build({evergreen: true}).must_be_instance_of Evergreen }
  it { Song.build({hit: true}).must_be_instance_of Hit }

  # test chained builds.
  class Track
    include Uber::Builder

    builds do |options|
      Evergreen if options[:evergreen]
    end

    builds do |options|
      Hit if options[:hit]
    end

    def self.build(options)
      class_builder.call(options).new
    end
  end

  it { Track.build({}).must_be_instance_of Track }
  it { Track.build({evergreen: true}).must_be_instance_of Evergreen }
  it { Track.build({hit: true}).must_be_instance_of Hit }


  # test inheritance. builder do not inherit.
  class Play < Song
  end

  it { Play.build({}).must_be_instance_of Play }
  it { Play.build({evergreen: true}).must_be_instance_of Play }
  it { Play.build({hit: true}).must_be_instance_of Play }

  # test return from builds
  class Boomerang
    include Uber::Builder

    builds ->(options) do
      return Song if options[:song]
    end

    def self.build(options)
      class_builder.call(options).new
    end
  end

  it { Boomerang.build({}).must_be_instance_of Boomerang }
  it { Boomerang.build({song: true}).must_be_instance_of Song }
end


class BuilderScopeTest < MiniTest::Spec
  def self.builder_method(options)
    options[:from_builder_method] and return self
  end

  class Hit; end

  class Song
    class Hit
    end

    include Uber::Builder

    builds :builder_method # i get called first.
    builds ->(options) do  # and i second.
      self::Hit
    end

    def self.build(context, options={})
      class_builder(context).call(options)
    end
  end

  class Evergreen
    class Hit
    end

    include Uber::Builder

    class << self
      attr_writer :builders
    end
    self.builders = Song.builders

    def self.build(context, options={})
      class_builder(context).call(options)
    end

    def self.builder_method(options)
      options[:from_builder_method] and return self
    end
  end

  it do
    Song.build(self.class).must_equal BuilderScopeTest::Hit

    # this runs BuilderScopeTest::builder_method and returns self.
    Song.build(self.class, from_builder_method: true).must_equal BuilderScopeTest

    # since the class_builder gets cached, this won't change.
    Song.build(Song).must_equal BuilderScopeTest::Hit
  end


  it do
    # running the "copied" block in Evergreen will reference the correct @context.
    Evergreen.build(Evergreen).must_equal BuilderScopeTest::Evergreen::Hit

    Evergreen.build(Evergreen, from_builder_method: true).must_equal BuilderScopeTest::Evergreen
  end
end


class DeeplyNestedBuilderTest < MiniTest::Spec
  class FromOutside
  end

  class Parent
    include Uber::Builder

    builds ->(params) do
      return Sub if params[:sub]
    end

    def self.build(options)
      class_builder.call(options).new
    end

    class Sub < self

      builds ->(params) do
        return DeepSub if params[:deep_sub]
        return FromOutside if params[:outside]
      end

      class DeepSub < self

        builds do |params|
          if params[:very_deep_sub]
            VeryDeepSub
          elsif  params[:outside]
            FromOutside
          end
        end

        class VeryDeepSub < self
          # and I can go even further!!!!
        end
      end
    end
  end

  it { Parent.build({}).must_be_instance_of Parent }
  it { Parent.build({sub: true})
    .must_be_instance_of Parent::Sub }
  it { Parent.build({sub: true, deep_sub: true})
    .must_be_instance_of Parent::Sub::DeepSub }
  it { Parent.build({sub: true, deep_sub: true, very_deep_sub: true})
    .must_be_instance_of Parent::Sub::DeepSub::VeryDeepSub }

  # calling a class that's not inherited
  it { Parent.build({outside: true}).must_be_instance_of Parent }
  it { Parent.build({sub: true, outside: true})
    .must_be_instance_of FromOutside }
  it { Parent.build({sub: true, deep_sub: true, outside: true})
    .must_be_instance_of FromOutside }
  it { Parent.build({sub: true, deep_sub: true, very_deep_sub: true, outside: true})
    .must_be_instance_of Parent::Sub::DeepSub::VeryDeepSub }
end