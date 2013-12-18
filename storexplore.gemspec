# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'storexplore/version'

Gem::Specification.new do |spec|
  spec.name          = "storexplore"
  spec.version       = Storexplore::VERSION
  spec.authors       = ["Philou"]
  spec.email         = ["philippe.bourgau@gmail.com"]
  spec.description   = %q{A declarative scrapping DSL that lets one define directory like apis to an online store}
  spec.summary       = %q{Online store scraping library}
  spec.homepage      = "https://github.com/philou/storexplore"
  spec.license       = "LGPL v3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
