require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'bundler'

Bundler::GemHelper.install_tasks


desc 'Generate documentation for the google_storage gem'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Google Storage'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
