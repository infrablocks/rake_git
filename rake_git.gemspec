# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_git/version'

files = %w[
  bin
  lib
  CODE_OF_CONDUCT.md
  rake_git.gemspec
  Gemfile
  LICENSE.txt
  Rakefile
  README.md
]

Gem::Specification.new do |spec|
  spec.name = 'rake_git'
  spec.version = RakeGit::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.summary = 'Rake tasks for interacting with git.'
  spec.description =
    'Allows performing git actions such as committing.'
  spec.homepage = 'https://github.com/infrablocks/rake_git'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(/^(#{files.map { |g| Regexp.escape(g) }.join('|')})/)
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'colored2', '~> 3.1'
  spec.add_dependency 'rake_factory', '0.32.0.pre.2'

  spec.metadata['rubygems_mfa_required'] = 'false'
end
