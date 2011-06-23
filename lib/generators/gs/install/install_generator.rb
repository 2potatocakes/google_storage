# encoding: utf-8

module GoogleStorage
  # Copies a google_storage.yml file into your applications config directory and a rake file
  # into your lib/tasks directory

  class InstallGenerator < Rails::Generators::Base
    desc "Copies a google_storage.yml file into your application"
    source_root File.expand_path('../../../templates', __FILE__)

    "Copies a google_storage.yml file into your applications config directory and a rake file into lib/tasks"
    def generate_layout
      copy_file        'google_storage.yml', 'config/google_storage.yml'
      copy_file        'google_storage.rake', 'lib/tasks/google_storage.rake'
    end

  end
end
