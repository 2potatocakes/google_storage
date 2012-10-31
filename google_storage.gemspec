# -*- encoding: utf-8 -*-
require File.expand_path('../lib/google_storage/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name              = 'google_storage'
  gem.version           = GoogleStorage::VERSION
  gem.platform          = Gem::Platform::RUBY
  gem.authors           = ['Lucas Hills']
  gem.email             = ['lucas@lucashills.com']
  gem.homepage          = 'https://github.com/2potatocakes/google_storage'
  gem.summary           = 'Google Storage for Developers is a RESTful service for storing and accessing your data on Google\'s infrastructure'
  gem.description       = 'A Ruby client library for using the new Google Storage API v2 using OAuth2.0'
  gem.files             = `git ls-files`.split($\)
  gem.executables       = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files        = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths     = ['lib']

  gem.add_dependency('crack')
end
