# -*- encoding: utf-8 -*-
require File.expand_path('../lib/light_service/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Attila Domokos"]
  gem.email         = ["adomokos@gmail.com"]
  gem.description   = %q{A service skeleton with an emphasis on simplicity}
  gem.summary       = %q{A service skeleton with an emphasis on simplicity}
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "light_service"
  gem.require_paths = ["lib"]
  gem.version       = LightService::VERSION

  gem.add_development_dependency("rspec", "~> 2.0")
  gem.add_development_dependency("simplecov", "~> 0.7.1")
end
