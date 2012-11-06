
require 'webmock'
require 'vcr'
require File.expand_path('secret_data', File.dirname(__FILE__))

#GS_YML_LOCATION = File.expand_path('../support/full_control_gs.yml', File.dirname(__FILE__))
GS_YML_LOCATION = File.expand_path('../support/google_storage.yml', File.dirname(__FILE__))

GS_BUCKET_MATCHER = lambda do |request_1, request_2|
  (request_1.uri.to_s.match(/https?:\/\/.*\.storage.googleapis.com\//).length ==
    request_2.uri.to_s.match(/https?:\/\/.*\.storage.googleapis.com\//).length) rescue false
end

GS_QUERY_STRING_MATCHER = lambda do |request_1, request_2|
  request_1.parsed_uri.query == request_2.parsed_uri.query
end

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path('../cassettes', File.dirname(__FILE__))
  c.hook_into :webmock
  c.default_cassette_options = { :record => :none } #:all to develop with, change to :none when checking in
  #c.configure_rspec_metadata!
  SecretData.new(GS_YML_LOCATION).silence! do |find, replace|
    # https://www.relishapp.com/myronmarston/vcr/docs/configuration/filter-sensitive-data
    c.filter_sensitive_data(replace) { find }
  end

  c.filter_sensitive_data('____SILENCED_access_token____') do |interaction|
    interaction.request.headers['authorization'].first if interaction.request.headers['authorization']
  end
  c.filter_sensitive_data('____SILENCED_access_token____') do |interaction|
    interaction.request.headers['Authorization'].first if interaction.request.headers['Authorization']
  end
  c.filter_sensitive_data('____SILENCED_access_token____') do |interaction|
    if interaction.response.body =~ /"access_token" : "[^"]*/
      $&.gsub(/"access_token" : "/, "")
    end
  end
  c.filter_sensitive_data('____SILENCED_refresh_token____') do |interaction|
    if interaction.response.body =~ /"refresh_token" : "[^"]*/
      $&.gsub(/"refresh_token" : "/, "")
    end
  end
  4.times do |i|
    c.filter_sensitive_data('____SILENCED_google_project_id____') do |interaction|
      unless interaction.response.body.scan(/<ID>[^<]*<\/ID>/)[i].nil?
        interaction.response.body.scan(/<ID>[^<]*<\/ID>/)[i].gsub(/(<ID>|<\/ID>)/, "")
      end
    end
  end
  c.filter_sensitive_data('____SILENCED_auth_code____') do |interaction|
    if interaction.request.body =~ /code=[^&]*/
      $&.gsub(/code=/, "")
    end
  end
end