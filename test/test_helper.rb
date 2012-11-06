
require 'rubygems'
require 'fileutils'
require 'yaml'
require 'net/https'
require 'uri'
require 'test/unit'
require 'vcr'
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require "google_storage"


require File.expand_path('../spec/support/shared_test_config', File.dirname(__FILE__))

module GSTestHelpers

  def cassette_dir
    VCR.configuration.cassette_library_dir
  end

  def tiny_test_object
    File.expand_path("../spec/support/thumbs.jpg", File.dirname(__FILE__))
  end

  def validate_successful_response_format(resp_obj)
    assert resp_obj[:success] == true
    assert resp_obj[:message].is_a?(String)
  end

  def validate_failed_response_format(resp_obj)
    assert resp_obj[:success] == false
    assert resp_obj[:message].is_a?(String)
    assert resp_obj.has_key?(:raw)
  end
end

