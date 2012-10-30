source "http://rubygems.org"

# Specify your gem's dependencies in google_storage.gemspec
gemspec

group :development do
  # Watch file change events instead of polling
  gem 'rb-fsevent', :require => false,        :group => :darwin              # OSX
  gem 'rb-inotify', :require => false,        :group => :linux               # Linux
  gem 'wdm',        :require => false,        :platforms => [:mswin, :mingw] # Windows
end
