require 'net/https'
require 'cgi'

module GoogleStorage
  class Client

    protected

    def construct_post_request(host, path, headers={}, params={}, options={})
      headers["Host"]           = host
      headers["Date"]           = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      headers["Content-Type"]   = 'application/x-www-form-urlencoded'
      headers["Content-Length"] = "0"
      Crack::JSON.parse(_post_http_request(host, path, params, headers, options[:data]))
    end

    def construct_http_request(host, path, method, headers={}, params={}, options={})
      raise "\nYou need to acquire a refresh_token before you can make requests to the Google API\n" unless @refresh_token
      headers["Host"]               = host
      headers["Date"]               = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      headers["Content-Type"]       = options[:content_type] ? options[:content_type] : 'binary/octet-stream'
      headers["Content-Length"]     = (options[:data] ? options[:data].size : 0).to_s
      headers["x-goog-api-version"] = @api_version
      headers["x-goog-project-id"]  = @project_id if options[:send_goog_project_id]
      headers["Authorization"]      = 'Bearer ' + @access_token
      param_string                  = params.empty? ? '' : '?' + params_to_data_string(params)
      headers["Range"]              = options[:range] if options[:range]
      headers["If-Match"]           = options[:filename] if options[:filename]
      headers["If-Modified-Since"]  = options[:if_modified_since] if options[:if_modified_since]
      headers["If-None-Match"]      = options[:if_none_match] if options[:if_none_match]
      headers["If-Unmodified-Since"]= options[:if_modified_since] if options[:if_modified_since]
      headers["Content-MD5"]        = options[:md5] if options[:md5]
      headers["x-goog-acl"]         = options[:x_goog_acl] if options[:x_goog_acl]
      headers["Transfer-Encoding"]  = options[:transfer_encoding] if options[:transfer_encoding]

      request = _http_request(host, path, method, headers, param_string, options[:data])
      if request.class == Net::HTTPUnauthorized
        warn "Token expired, will attempt to get a new one" if @debug
        @access_token = self.refresh_access_token(@refresh_token)["access_token"]
        headers["Authorization"]      = 'Bearer ' + @access_token
        request = _http_request(host, path, method, headers, param_string, options[:data])
      end
      request
    end

    private

    def _post_http_request(host, path, params, headers, data=nil)
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.set_debug_output $stderr if @debug
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      data ||= params_to_data_string(params)
      resp = http.post(path, data, headers)

      return resp.body
    end


    def _http_request(host, path, method, headers, param_string, data=nil)
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.set_debug_output $stderr if @debug
      http.read_timeout = @timeout ? @timeout : 15
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = method.new(path + param_string)
        headers.each do |key, value|
          req[key.to_s] = value
        end

      response = http.start { http.request(req, data) }
      return response
      rescue Timeout::Error
        $stderr.puts "Timeout accessing #{path}: #{$!}"
        nil
      rescue
        $stderr.puts "Error accessing #{path}: #{$!}"
        nil
    end

    def params_to_data_string(params)
      return "" if params.empty?
      esc_params = params.collect do |p|
        encoded = (CGI::escape(p[0].to_s) + "=" + CGI::escape(p[1].to_s))
        encoded.gsub('+', '%20')
      end
      "#{esc_params.join('&')}"
    end
  end
end