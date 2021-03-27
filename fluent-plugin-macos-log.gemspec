# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

version = File.read('version.txt').strip

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-macos-log"
  spec.version       = version
  spec.authors       = ["Petr Langr"]
  spec.email         = ["technicalsupport@solarwinds.com"]

  spec.summary       = %q{Fluentd input plugin for MacOS unified log}
  spec.description   = %q{Fluentd input plugin for MacOS unified log}
  spec.homepage      = "https://github.com/loggly/fluent-plugin-macos-log"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = ">= 2.3.0"
  spec.required_rubygems_version = ">= 3.0.1"

  spec.add_dependency "fluentd", '>= 1.2', '< 2'
  spec.add_dependency "yajl-ruby", '~> 1.3'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "test-unit", "~> 3.2"
end