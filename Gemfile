source "http://rubygems.org"

# Specify your gem's dependencies in google_storage.gemspec
gemspec

gem 'jruby-openssl', :platforms => :jruby

group :test, :development do
  gem 'uuid'
  gem 'rake', '0.8.7'
  gem 'rspec'
  gem 'simplecov'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'rdoc'
  gem 'yard'
  gem 'RedCloth'

  gem 'guard-test'
  gem 'guard-rspec'
  gem 'guard-bundler'

  # Watch file change events instead of polling
  gem 'rb-fsevent', :require => false, :group => :darwin              # OSX
  gem 'rb-inotify', :require => false, :group => :linux               # Linux
  gem 'wdm',        :require => false, :platforms => [:mswin, :mingw] # Windows
end
