# -*- encoding: utf-8 -*-
require File.expand_path('../lib/uber/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nick Sutterer"]
  gem.email         = ["apotonick@gmail.com"]
  gem.description   = %q{A gem-authoring framework.}
  gem.summary       = %q{Uber is a gem-authoring framework that brings simple module inheritance and more.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "uber"
  gem.require_paths = ["lib"]
  gem.version       = Uber::VERSION
  
  gem.add_development_dependency "minitest", ">= 2.8.1"
end
