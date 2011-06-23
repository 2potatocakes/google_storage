require 'google_storage/request'
require 'google_storage/token'
require 'google_storage/bucket'
require 'google_storage/object'
require 'yaml'

module GoogleStorage
  
  class Client
    
    def initialize(options = {})

      if (options[:config_yml] && !options[:config_yml].nil?) || (defined?(Rails.root) && File.exists?(File.join(Rails.root, 'config', 'google_storage.yml')))
        config_path = options[:config_yml] ? File.expand_path(options[:config_yml]) : File.join(Rails.root, 'config', 'google_storage.yml')
      end

      raise " \nCan't find a google_storage.yml file to initialise with..
\nIf running inside a Rails Application
Please run: rails generate google_storage:install
To generate a google_storage.yml file in your config directory
\nIf running manually within a script or whatever
Initialise GoogleStorage with a path to your config yml file
Example: GoogleStorage::Client.new(:config_yml => 'path to your google storage yml')
\nIf running a rake task try passing: path='path to your google storage yml'
\n\n" unless config_path && File.exists?(config_path)

      config_yml = YAML::load(File.open(config_path))

      @project_id     = config_yml['google_config']['x-goog-project-id']

      @client_id      = config_yml['web_applications']['client_id']
      @client_secret  = config_yml['web_applications']['client_secret']
      @client_secret.force_encoding("UTF-8")
      @refresh_token  = config_yml['refresh_token'] if config_yml['refresh_token']

      #TODO Add support for individual permission types
      if config_yml['google_storage_ids']
        @gsid_you       = config_yml['google_storage_ids']['you'] if config_yml['google_storage_ids']['you']
        @gsid_owners    = config_yml['google_storage_ids']['owners'] if config_yml['google_storage_ids']['owners']
        @gsid_editors   = config_yml['google_storage_ids']['editors'] if config_yml['google_storage_ids']['editors']
        @gsid_team      = config_yml['google_storage_ids']['team'] if config_yml['google_storage_ids']['team']
      end

      #TODO - make redirect_uri's support multiple urls
      @redirect_uri   = config_yml['web_applications']['redirect_uris']
      #TODO - maybe add support for API v1 as well... but probably not..
      @api_version    = options[:x_goog_api_version] ? options[:x_goog_api_version] : 2
      @debug          = options[:debug]
      @timeout        = options[:timeout]
      @host           = options[:host] ? options[:host] : 'commondatastorage.googleapis.com'
    end

    def google_storage_id(id)
      case id
        when :you
          @gsid_you
        when :owners
          @gsid_owners
        when :editors
          @gsid_editors
        when :team
          @gsid_team
      end
    end

    private
      
      def get(bucket, path, options={})
        http_request(Net::HTTP::Get, bucket, path, options)
      end
      
      def put(bucket, path, options={})
        http_request(Net::HTTP::Put, bucket, path, options)
      end
      
      def delete(bucket, path, options={})
        http_request(Net::HTTP::Delete, bucket, path, options)
      end
      
      def head(bucket, path, options={})
        http_request(Net::HTTP::Head, bucket, path, options)
      end

      def post_request(host, path, token, options={})
        params = options.delete(:params) || {}
        headers = options.delete(:headers) || {}
        params[:"client_id"]      = @client_id
        params[:"client_secret"]  = @client_secret
        params[:"grant_type"]     = options['grant_type']

        case options['grant_type']
          when 'authorization_code'
            params[:"code"]           = token
            params[:"redirect_uri"]   = @redirect_uri
          when 'refresh_token'
            params[:"refresh_token"]  = token
        end

        construct_post_request(host, path, headers, params, options)
      end
      
      def http_request(method, bucket, path, options={})
        host = bucket ? "#{bucket}.#{@host}" : @host
        params = options.delete(:params) || {}
        headers = options.delete(:headers) || {}
        construct_http_request(host, path, method, headers, params, options)
      end
      
  end
end
   
