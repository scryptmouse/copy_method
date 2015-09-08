# CopyMethod [![Build Status](https://travis-ci.org/scryptmouse/copy_method.svg?branch=master)](https://travis-ci.org/scryptmouse/copy_method)

Here there be dragons.

This is an experiment in copying / moving methods between Ruby classes and modules. The idea is to ultimately
allow metaprogramming that works with something like Python's decorators, without excessive use of `alias_method`
and the like. In other words, preserving `super` / inheritance / method overriding.

It mostly works, though it's very, very experimental and has a few caveats. Methods created with `class_eval` or
`define_method` will _not_ work. It adds a generated helper module to the target class that will preserve
constant lookups, but obviously if the copied method calls any methods defined on the origin, it expects
those to exist on the target.

The method used here is different from delegation as it copies the _entire_ method to the target class or module,
any changes to the original method won't propagate (by design).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'copy_method'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install copy_method

## Usage

```ruby
class Animal
  def eat
  end

  def sleep
  end

  # It'll work with these types of class methods
  def self.vertebrates
  end

  class << self
    # Or these
    def mammals
    end
  end
end

class Animal2
end

module Abilities
end

Animal.include Abilities

CopyMethod.copy :eat, from: Animal, to: Abilities
# `move` is shorthand for passing `remove: true` to `copy`
CopyMethod.move :sleep, from: Animal, to: Abilities

CopyMethod.copy_singleton :vertebrates, from: Animal, to: Animal2
```

### Note about singleton methods and modules

There's some special logic with copying singleton methods from a class to a module. In such a scenario,
unless specified otherwise, copying the method will place it in the target module's `instance_methods`,
so that any class that `extend`s it will be able to use those as class methods.

```ruby
module Scopes
end

Animal.extend Scopes

CopyMethod.move_singleton :vertebrates, from: Animal, to: Scopes

Animal.respond_to? :vertebrates # => true
Scopes.respond_to? :vertebrates # => false
Scopes.instance_method(:vertebrates) # => #<UnboundMethod: Scopes#vertebrates>
```

If you want to actually copy it to the target module's `methods`, use the `singleton_target` option:

```ruby
CopyMethod.move_singleton :mammals, from: Animal, to: Scopes, singleton_target: true

Animal.respond_to? :mammals # => false
Scopes.respond_to? :mammals # => true
Scopes.method(:mammals) # => #<Method: Scopes.mammals>
```

None of this applies when copying _to_ a class, _from_ a module, or between modules.

### Why not just use modules?

Because this is an experiment for tinkering with some other metaprogramming projects. `Module.prepend` allows
for so many improved features, but there are still a few edge cases.

## Development

### TODO

* More tests
* Handle subclasses. If `Cat < Animal`, and we want to remove a method from `Cat` that is defined on `Animal`, specify the behavior.
* Add logic to ensure recopying a copied method will work (specifically the constants helper module)
* More tests
* More documentation
* More tests?

## Contributing

Bug reports and pull requests are welcome on GitHub at ( https://github.com/scryptmouse/copy_method ). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
