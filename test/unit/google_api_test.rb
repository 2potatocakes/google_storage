

require File.expand_path("../test_helper", File.dirname(__FILE__))
require "uuid"

class GoogleAPITest < Test::Unit::TestCase

  include GSTestHelpers

  def setup
    VCR.use_cassette('setup_client') do
      #Flick debug over to true to help debug
      @client = GoogleStorage::Client.new(:config_yml => GS_YML_LOCATION, :debug => false)
    end

    @test_bucket = "gs-test-#{UUID.new.generate(:compact)}"
    @test_object = tiny_test_object
  end

  def teardown
    VCR.use_cassette('teardown', :match_requests_on => [:method, GS_BUCKET_MATCHER]) do
      @client.delete_bucket(@test_bucket)
    end
  end

  def create_bucket(public = false)
    VCR.use_cassette('create_buckets', :match_requests_on => [:method, GS_BUCKET_MATCHER]) do
      create_response = public ?
          @client.create_bucket(@test_bucket, :x_goog_acl => 'public-read') :
          @client.create_bucket(@test_bucket)
      validate_successful_response_format(create_response)
      assert_equal "Bucket created", create_response[:message]
      assert_equal @test_bucket, create_response[:bucket_name]
    end
  end

  def test_list_buckets
    VCR.use_cassette('list_buckets') do
      response = @client.list_buckets
      validate_successful_response_format(response)
      assert response[:buckets].is_a?(Array)
    end
  end

  def test_get_bucket_contents
    create_bucket
    VCR.use_cassette('get_bucket',
        :match_requests_on => [:method, GS_BUCKET_MATCHER, GS_QUERY_STRING_MATCHER, :body]) do
      get_response = @client.get_bucket(@test_bucket)
      validate_successful_response_format(get_response)
      assert_nil get_response[:contents]
    end
  end

  def test_destroy_private_bucket
    create_bucket
    VCR.use_cassette('destroy_bucket',
        :match_requests_on => [:method, GS_BUCKET_MATCHER]) do
      verify_public_access_is_available(false)

      delete_response = @client.delete_bucket(@test_bucket)
      validate_successful_response_format(delete_response)
      assert_equal "Bucket deleted", delete_response[:message]
      assert_equal @test_bucket, delete_response[:bucket_name]

      get_response = @client.get_bucket(@test_bucket)
      validate_failed_response_format(get_response)
      assert_equal "The specified bucket does not exist.", get_response[:message]
      assert_nil get_response[:contents]
      assert_equal @test_bucket, get_response[:bucket_name]
    end
  end

  def test_destroy_public_bucket
    create_bucket(true)
    VCR.use_cassette('public_bucket_creation_and_access',
        :match_requests_on => [:method, GS_BUCKET_MATCHER, GS_QUERY_STRING_MATCHER, :body]) do

      verify_public_access_is_available(true)

      delete_response = @client.delete_bucket(@test_bucket)
      validate_successful_response_format(delete_response)
      assert_equal "Bucket deleted", delete_response[:message]
      assert_equal @test_bucket, delete_response[:bucket_name]

      get_response = @client.get_bucket(@test_bucket)
      validate_failed_response_format(get_response)
      assert_equal "The specified bucket does not exist.", get_response[:message]
      assert_nil get_response[:contents]
      assert_equal @test_bucket, get_response[:bucket_name]
    end
  end

  def test_duplicate_bucket_creation_response

    create_bucket
    VCR.use_cassette('duplicate_bucket_creation',
        :match_requests_on => [:method, GS_BUCKET_MATCHER, GS_QUERY_STRING_MATCHER, :body]) do

      get_response = @client.get_bucket(@test_bucket)
      validate_successful_response_format(get_response)
      assert_nil get_response[:contents]
      assert_equal @test_bucket, get_response[:bucket_name]
      assert get_response.has_key?(:raw)

      create_response = @client.create_bucket(@test_bucket)
      validate_failed_response_format(create_response)
      assert_equal "Your previous request to create the named bucket succeeded and you already own it.",
                   create_response[:message]
      assert_equal @test_bucket, create_response[:bucket_name]
      assert_equal "BucketAlreadyOwnedByYou", create_response[:code]
    end
  end

  def test_get_bucket_acl
    create_bucket
    VCR.use_cassette('get_bucket_acl',
        :match_requests_on => [:method, GS_BUCKET_MATCHER, GS_QUERY_STRING_MATCHER, :body]) do
      acl_response = @client.bucket_acls(@test_bucket)
      validate_successful_response_format(acl_response)
      assert_equal @test_bucket, acl_response[:bucket_name]
      assert acl_response.has_key?(:acl)
      assert acl_response.has_key?(:raw)
    end
  end

  private

  def verify_public_access_is_available(public_access = true)
    uri = URI.parse("http://#{@test_bucket}.storage.googleapis.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.start {
      http.request_get("/") {|response|
        if public_access
          #Assert public access is available to this bucket URL
          assert_equal 200, response.code.to_i
          assert response.body.match(/<Name>gs-test.*<\/Name>/)
        else
          #Assert public access is forbidden to this bucket URL
          assert_equal 403, response.code.to_i
          assert_equal "Forbidden", response.message
        end

      }
    }

  end

end
