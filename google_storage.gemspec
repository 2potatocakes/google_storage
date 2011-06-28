# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "google_storage/version"

Gem::Specification.new do |s|
  s.name        = 'google_storage'
  s.version     = GoogleStorage::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Lucas Hills']
  s.email       = ['lucas@lucashills.com']
  s.homepage    = 'https://github.com/2potatocakes/google_storage'
  s.summary     = 'Google Storage for Developers is a RESTful service for storing and accessing your data on Google\'s infrastructure'
  s.description = 'A Ruby client library for using the new Google Storage API v2 using OAuth2.0'
  s.files       = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency('crack')
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.textile']
end