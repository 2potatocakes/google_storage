
require 'digest/md5'

module GoogleStorage
  class Client

    def get_object(bucket, filename, options={})
      filename.gsub!(/^\//, "")
      resp = get(bucket, "/#{filename}", options)
      return Crack::XML.parse(resp.body) unless resp.code == "200"
      resp_obj = {}
      if options[:write_to_file]
        begin
          File.open(options[:write_to_file], 'wb') {|f| f.write(resp.body) }
        rescue Exception => msg
          return {:error => msg}
        end
        resp_obj.clear
        resp_obj[:success]      = true
        resp_obj[:message]      = "File created"
        resp_obj[:path_to_file] = options[:write_to_file]
        return resp_obj
      end
      resp_obj[:success]   = true
      resp_obj[:filename] = filename
      resp_obj[:body]     = resp.body
      resp_obj[:type]     = resp.header["content-type"]
      resp_obj[:size]     = resp.header["content-length"]

      return resp_obj
    end

    def put_object(bucket, filename, options={})
      filename.gsub!(/^\//, "")
      if options[:path_to_file]
        begin
          uploaded_file = File.open(options[:path_to_file])
          if uploaded_file.respond_to?(:get_input_stream)
            uploaded_file.get_input_stream { |io| @data = io.read }
          else
            uploaded_file.binmode
            @data = uploaded_file.read
          end
        rescue Exception => msg
          return {:error => msg}
        end
        options[:data] = @data
      end
      resp = put(bucket, "/#{filename}", options)
      public_file = (options[:x_goog_acl] && options[:x_goog_acl].match(/public/))
      return Crack::XML.parse(resp.body) unless resp.code == "200"
      resp_obj = {}
      resp_obj[:success]      = true
      resp_obj[:message]      = "Object added successfully"
      resp_obj[:filename]     = filename
      resp_obj[:content_type] = options[:content_type]
      resp_obj[:url]          = public_file ? "http://#{@host}/#{bucket}/#{filename}" : \
                                              "https://sandbox.google.com/storage/#{bucket}/#{filename}"
      resp_obj[:url_type]     = public_file ? "public" : "private"
      return resp_obj
    end

    def list_acls_for_object(bucket, filename, options={})
      filename.gsub!(/^\//, "")
      resp = get(bucket, "/#{filename}?acl", options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp_obj["AccessControlList"]
        resp_obj[:success] = true
        resp_obj[:object_name] = filename
        resp_obj[:acl] = resp_obj["AccessControlList"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless key == :success || key == :object_name || key == :acl || key == :raw }
      end
      return resp_obj
    end

    alias :object_acls :list_acls_for_object

    def head_object(bucket, filename, options={})
      filename.gsub!(/^\//, "")
      resp = head(bucket, "/#{filename}", options)
      return resp.header unless resp.code == "200"
      resp_obj = {}
      resp_obj[:success]          = true
      resp_obj[:filename]         = filename
      resp_obj[:last_modified]    = resp.header['last-modified'] if resp.header['last-modified']
      resp_obj[:etag]             = resp.header['etag'] if resp.header['etag']
      resp_obj[:content_length]   = resp.header['content-length'] if resp.header['content-length']
      resp_obj[:content_type]     = resp.header['content-type'] if resp.header['content-type']
      resp_obj[:cache_control]    = resp.header['cache-control'] if resp.header['cache-control']
      resp_obj[:date]             = resp.header['date'] if resp.header['date']
      return resp_obj
    end

    alias :object_head :head_object

    def delete_object(bucket, filename, options={})
      filename.gsub!(/^\//, "")
      resp = delete(bucket, "/#{filename}", options)
      return Crack::XML.parse(resp.body) unless resp.code == "204"
      resp_obj = {}
      resp_obj[:success]          = true
      resp_obj[:message]          = "Object deleted successfully"
      return resp_obj
    end
  end
end