

require File.expand_path("../test_helper", File.dirname(__FILE__))

class TokenTest < Test::Unit::TestCase

  include GSTestHelpers

  def setup
    VCR.use_cassette('unauthorized_client') do
      @client = GoogleStorage::Client.new(:config_yml => GS_YML_LOCATION)
    end
  end

  #TODO
  #def test_read_only_authorization_url_response
  #  VCR.use_cassette('token_authorization') do
  #    uri = URI.parse(@client.authorization_url(:read_only))
  #    http = Net::HTTP.new(uri.host, uri.port)
  #    http.use_ssl = true # enable SSL/TLS
  #    http.start {
  #      http.request_get(uri.path + "?" + uri.query) {|response|
  #        assert_equal 302, response.code.to_i
  #        assert response.body.match(
  #                   Regexp.escape(@client.redirect_uri)
  #               )
  #      }
  #    }
  #  end
  #end

  def test_acquire_refresh_token

    VCR.use_cassette('refresh_token', :record => :once) do
      #
      #To retest this test, you'll need to first delete the spec/cassettes/refresh_token.yml file
      #Then manually acquire an authentication token online first and paste it in below
      #
      #FileUtils.rm File.expand_path("refresh_token.yml", cassette_dir) if \
      #  File.exists?(File.expand_path("refresh_token.yml", cassette_dir))
      #client = GoogleStorage::Client.new(:config_yml => GS_YML_LOCATION)
      #puts client.authorization_url(:read_only)

      token = @client.acquire_refresh_token('4/ZIH1clCkeH1zTqVWwocohcbHWOWK.Iuf8pyJxE_UegrKXntQAax3eoiCrdQI')
      assert_not_equal "Failed to acquire a refresh token. Something went wrong. Try getting a new Auth code.",
                       token
    end
  end

end
