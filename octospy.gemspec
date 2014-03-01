# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octospy/version'

Gem::Specification.new do |spec|
  spec.name          = 'octospy'
  spec.version       = Octospy::VERSION
  spec.authors       = ['linyows']
  spec.email         = ['linyows@gmail.com']
  spec.description   = %q{This is IRC bot that notifies repository activity on github.}
  spec.summary       = %q{Octospy notifies the repository activity to an IRC channel.}
  spec.homepage      = 'https://github.com/linyows/octospy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'cinch', '~> 2.0'
  spec.add_dependency 'octokit', '~> 2.7'
  spec.add_dependency 'string-irc', '~> 0.3'
  spec.add_dependency 'faraday', '~> 0.8.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'
  spec.add_dependency 'dotenv', '~> 0.10'
end
