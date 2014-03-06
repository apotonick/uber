# Uber

_Gem-authoring tools like class method inheritance in modules, dynamic options and more._

## Installation

Add this line to your application's Gemfile:

    gem 'uber'

Ready?

# Inheritable Class Attributes

This is for you if you want class attributes to be inherited, which is a mandatory mechanism for creating DSLs.

```ruby
require 'uber/inheritable_attr'

class Song
  extend Uber::InheritableAttr

  inheritable_attr :properties
  self.properties = [:title, :track] # initialize it before using it.
end
```

Note that you have to initialize your attribute which whatever you want - usually a hash or an array.

You can now use that attribute on the class level.

```ruby
Song.properties #=> [:title, :track]
```

Inheriting from `Song` will result in the `properties` object being `clone`d to the sub-class.

```ruby
class Hit < Song
end

Hit.properties #=> [:title, :track]
```

The cool thing about the inheritance is: you can work on the inherited attribute without any restrictions, as it is a _copy_ of the original.

```ruby
Hit.properties << :number

Hit.properties  #=> [:title, :track, :number]
Song.properties #=> [:title, :track]
```

It's similar to ActiveSupport's `class_attribute` but with a simpler implementation resulting in a less dangerous potential. Also, there is no restriction about the way you modify the attribute [as found in `class_attribute`](http://apidock.com/rails/v4.0.2/Class/class_attribute).

This module is very popular amongst numerous gems like Cells, Representable, Roar and Reform.


# Options

Implements the pattern of defining configuration options and evaluating them at run-time.

Usually DSL methods accept a number of options that can either be static values, instance method names as symbols, or blocks (lambdas/Procs).

Uber::Options.new volume: 9, track: lambda { |s| s.track }


Note that `Options` behaves *and performs* like an ordinary hash when all options are static.

only use for declarative assets, not at runtime (use a hash)


# License

Copyright (c) 2014 by Nick Sutterer <apotonick@gmail.com>

Roar is released under the [MIT License](http://www.opensource.org/licenses/MIT).