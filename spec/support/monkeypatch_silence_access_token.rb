require 'google_storage'
require 'vcr'

module GoogleStorage
  class Client
    def after_refresh_access_token(response)
      VCR.configure do |c|
        c.filter_sensitive_data('____SILENCED_access_token____') do
          response['access_token']
        end
      end
    end
  end
end
