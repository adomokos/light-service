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

  gem.add_dependency("activesupport", ">= 3.0")

  gem.add_development_dependency("rspec", "~> 3.0")
  gem.add_development_dependency("rspec-its", "~> 1.0")
  gem.add_development_dependency("simplecov", "~> 0.7.1")
  gem.add_development_dependency("pry", "0.9.12.2")
end
