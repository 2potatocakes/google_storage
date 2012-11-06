require 'spec_helper'
require 'uuid'

describe "GoogleStorageClient" do

  before(:all) do
    VCR.use_cassette('setup_client') do
      @client = GoogleStorage::Client.new(:config_yml => GS_YML_LOCATION)
    end
  end

  before(:each) do
    VCR.use_cassette('create_buckets', :match_requests_on => [:method, GS_BUCKET_MATCHER]) do
      @test_bucket = "gs-test-#{UUID.new.generate(:compact)}"
      @client.create_bucket(@test_bucket)
    end
  end

  after(:each) do
    VCR.use_cassette('cleanup_buckets', :match_requests_on => [:method, GS_BUCKET_MATCHER]) do
      @client.delete_bucket(@test_bucket)
    end
  end

  context "when webcfg exists" do
    use_vcr_cassette "webcfg_exists", :match_requests_on => [:method, :host, GS_QUERY_STRING_MATCHER, :body]

    before(:each) do
      @client.set_webcfg(@test_bucket, {'MainPageSuffix' => 'index.html', 'NotFoundPage' => '404.html'})
    end

    it "get existing webcfg" do
      resp = @client.get_webcfg(@test_bucket)

      resp[:success].should be_true
      resp[:bucket_name].should == @test_bucket
      resp[:message].should == "Website configuration retrieved"
      resp[:config].should == {
          'MainPageSuffix'  =>  'index.html',
          'NotFoundPage'    =>  '404.html'
      }
      resp.has_key?(:raw).should be_true
    end

    it "clears the existing webcfg from bucket" do
      resp = @client.set_webcfg(@test_bucket, nil)
      resp[:success].should be_true
      resp[:bucket_name].should == @test_bucket
      resp[:message].should == 'Website Configuration successful'
    end
  end

  context "when webcfg does not exist" do
    use_vcr_cassette "webcfg_not_exists", :match_requests_on => [:method, :host, GS_QUERY_STRING_MATCHER, :body]

    it "sets new webcfg for bucket" do
      resp =  @client.set_webcfg(@test_bucket, {
          'MainPageSuffix'  =>  'index.html',
          'NotFoundPage'    =>  '404.html'
        })
      resp[:success].should be_true
      resp[:bucket_name].should == @test_bucket
      resp[:message].should == 'Website Configuration successful'
    end

    it "webcfg should be nil as does not exist" do
      resp = @client.get_webcfg(@test_bucket)
      resp[:success].should be_true
      resp[:bucket_name].should == @test_bucket
      resp[:message].should == "Website configuration retrieved"
      resp.has_key?(:config).should be_true
      resp[:config].should be_nil
      resp.has_key?(:raw).should be_true
    end
  end
end
