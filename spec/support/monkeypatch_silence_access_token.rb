require 'google_storage'
require 'vcr'

module GoogleStorage
  class Client
    def refresh_access_token(token, options={})
      options['grant_type'] = 'refresh_token'
      response = post_request('accounts.google.com', '/o/oauth2/token', token,
                              options)
      VCR.configure do |c| 
        c.filter_sensitive_data('____SILENCED_access_token____') do 
          response['access_token']
        end
      end
      response
    end
  end
end
