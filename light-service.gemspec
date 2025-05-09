# -*- encoding: utf-8 -*-
require File.expand_path('../lib/light-service/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Attila Domokos"]
  gem.email         = ["adomokos@gmail.com"]
  gem.description   = %q{A service skeleton with an emphasis on simplicity}
  gem.summary       = %q{A service skeleton with an emphasis on simplicity}
  gem.homepage      = "https://github.com/adomokos/light-service"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "light-service"
  gem.require_paths = ["lib"]
  gem.version       = LightService::VERSION
  gem.required_ruby_version = '>= 2.6.0'

  gem.add_dependency("activesupport", ">= 5.0", "< 9.0")

  gem.add_development_dependency("generator_spec", "~> 0.10")
  gem.add_development_dependency("test-unit", "~> 3.6") # Needed for generator specs.
  gem.add_development_dependency("rspec", "~> 3.13")
  gem.add_development_dependency("simplecov", "~> 0.22")
  gem.add_development_dependency("simplecov-cobertura", "~> 2.1")
  gem.add_development_dependency("rubocop", "~> 1.75")
  gem.add_development_dependency("rubocop-performance", "~> 1.2")
  gem.add_development_dependency("pry", "~> 0.15")
  gem.add_development_dependency("ostruct", "~> 0.6")
end
