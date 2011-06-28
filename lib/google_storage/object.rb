
require 'digest/md5'

module GoogleStorage
  class Client

    ###
    #
    # <b>Returns a Google Storage Object inside of a Hash</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#getobject
    #
    # Example:
    #
    #   Returns a Hash containing your object
    #     client.get_object('bucket_name', 'example_image.jpg')
    #
    #   Or write the file directly to your file system
    #     client.get_object('bucket_name', 'example_image.jpg', :write_to_file => 'C:/example/file.jpg')
    #
    ###

    def get_object(bucket_name, filename, options={})
      filename.gsub!(/^\//, "")
      resp = get(bucket_name, "/#{filename}", options)
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

    ###
    #
    # <b>Uploads an Object to Google Storage, or updates if using the same filename</b>
    #
    # If no :x_goog_acl option is supplied, a 'private' ACL is applied by default
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#putobject
    #
    # *Note:* If no content type is specified then Google defaults to using 'binary/octet-stream'
    #
    # Example:
    #
    #   client.put_object('bucket_name', 'file.jpg', :path_to_file => 'C:/example/file.jpg')
    #   client.put_object('bucket_name', 'file.jpg', :data => File.read('C:/example/file.jpg'))
    #
    # Available Options:
    #
    #   :x_goog_acl => 'public-read'
    #   :content_type => 'image/jpeg'     <-- It's recommended to always include the content type
    #   :path_to_file => 'path_to_file_you_want_to_upload'
    #   :data => [binary_data]
    #
    #
    ###

    def put_object(bucket_name, filename, options={})
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
      resp = put(bucket_name, "/#{filename}", options)
      public_file = (options[:x_goog_acl] && options[:x_goog_acl].match(/public/))
      return Crack::XML.parse(resp.body) unless resp.code == "200"
      resp_obj = {}
      resp_obj[:success]      = true
      resp_obj[:message]      = "Object added successfully"
      resp_obj[:filename]     = filename
      resp_obj[:content_type] = options[:content_type] ? options[:content_type] : 'binary/octet-stream'
      resp_obj[:url]          = public_file ? "http://#{@host}/#{bucket_name}/#{filename}" : \
                                              "https://sandbox.google.com/storage/#{bucket_name}/#{filename}"
      resp_obj[:url_type]     = public_file ? "public" : "private"
      return resp_obj
    end

    alias :upload_object :put_object

    ###
    #
    # <b>Lists the ACL that has been applied to a particular object</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#getobject
    #
    # Example:
    #
    #   client.object_acls('bucket_name', 'file.jpg')
    #
    ###

    def object_acls(bucket_name, filename, options={})
      filename.gsub!(/^\//, "")
      resp = get(bucket_name, "/#{filename}?acl", options)
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

    ###
    #
    # <b>Returns the metadata of an Object stored</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#headobject
    #
    # Example:
    #
    #   client.object_head('bucket_name', 'file.jpg')
    #
    ###

    def object_head(bucket_name, filename, options={})
      filename.gsub!(/^\//, "")
      resp = head(bucket_name, "/#{filename}", options)
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

    ###
    #
    # <b>Deletes an Object from your bucket</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#deleteobject
    #
    # Example:
    #
    #   client.delete_object('bucket_name', 'file.jpg')
    #
    ###

    def delete_object(bucket_name, filename, options={})
      filename.gsub!(/^\//, "")
      resp = delete(bucket_name, "/#{filename}", options)
      return Crack::XML.parse(resp.body) unless resp.code == "204"
      resp_obj = {}
      resp_obj[:success]          = true
      resp_obj[:message]          = "Object deleted successfully"
      return resp_obj
    end
  end
end