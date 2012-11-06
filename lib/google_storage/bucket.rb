
module GoogleStorage
  class Client

    ###
    #
    # <b>Lists all buckets available within your project</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#getservice
    #
    ###

    def list_buckets
      options = {}
      options[:send_goog_project_id] = true
      resp = get(nil, '/', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp_obj["ListAllMyBucketsResult"]
        resp_obj[:success] = true
        resp_obj[:message] = "Buckets retrieved successfully"
        resp_obj[:buckets] = []

        unless resp_obj["ListAllMyBucketsResult"]["Buckets"].nil?
          if resp_obj["ListAllMyBucketsResult"]["Buckets"]["Bucket"].is_a?(Hash)
            resp_obj[:buckets][0] = resp_obj["ListAllMyBucketsResult"]["Buckets"]["Bucket"]
          else
            resp_obj[:buckets] = resp_obj["ListAllMyBucketsResult"]["Buckets"]["Bucket"]
          end
        end

        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :buckets, :message, :raw].include?(key) }
      end
      return resp_obj
    end

    ###
    #
    # <b>Lists the ACL that has been applied to a bucket</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#getbucket
    #
    # Example:
    #
    #   client.bucket_acls('bucket_name')
    #
    ###

    def bucket_acls(bucket_name, options={})
      resp = get(bucket_name, '/?acl', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp_obj["AccessControlList"]
        resp_obj[:success] = true
        resp_obj[:message] = "ACL's retrieved successfully"
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:acl] = resp_obj["AccessControlList"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :acl, :raw].include?(key) }

      else
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj["Error"]["Message"].to_s if resp_obj["Error"]["Message"]
        resp_obj[:code] = resp_obj["Error"]["Code"] if resp_obj["Error"]["Code"]
        resp_obj[:details] = resp_obj["Error"]["Details"] if resp_obj["Error"]["Details"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :code, :details, :raw].include?(key) }

      end
      return resp_obj
    end

    ###
    #
    # <b>Creates a new bucket for your project and applies the 'project-private' ACL by default</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#putbucket
    #
    # You can apply a different ACL to a bucket by passing in an :x_goog_acl option and applying one of the predefined ACL's
    #
    # Example:
    #
    #     client.create_bucket('bucket_name')                                <-- private bucket
    #     client.create_bucket('bucket_name', :x_goog_acl => 'public-read')  <-- public readable bucket
    #
    # Available Options:
    #
    #   :x_goog_acl => 'public-read'
    #
    ###

    def create_bucket(bucket_name, options={})
      options[:send_goog_project_id] = true
      resp = put(bucket_name, '/', options)
      if resp.code == "200"
        resp_obj = {}
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = "Bucket created"

      else
        resp_obj = Crack::XML.parse(resp.body)
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj["Error"]["Message"].to_s
        resp_obj[:code] = resp_obj["Error"]["Code"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :code, :raw].include?(key) }

      end
      return resp_obj
    end

    ###
    #
    # <b>Returns a list of all Objects within a specified bucket</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#getbucket
    #
    # Example:
    #
    #     client.get_bucket('bucket_name')
    #
    ###

    def get_bucket(bucket_name, options={})
      resp = get(bucket_name, '/', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp.code == "200"
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = "Bucket retrieved successfully"
        contents = resp_obj["ListBucketResult"]["Contents"] ? Array.new : nil
        resp_obj["ListBucketResult"]["Contents"].is_a?(Array) ? \
          (contents = resp_obj["ListBucketResult"]["Contents"]) : \
          (contents[0] = resp_obj["ListBucketResult"]["Contents"]) unless contents.nil?
        resp_obj[:contents] = contents
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :contents, :raw].include?(key) }

      else
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj["Error"]["Message"]
        resp_obj[:contents] = nil
        resp_obj[:code] = resp_obj["Error"]["Code"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :contents, :code, :raw].include?(key) }

      end
      return resp_obj
    end

    ###
    #
    # <b>Deletes a specified bucket from your project</b>
    #
    # Google Ref: http://code.google.com/apis/storage/docs/reference-methods.html#deletebucket
    #
    # *Note:* You can only delete an empty bucket
    #
    # Example:
    #
    #     client.delete_bucket('bucket_name')
    #
    ###

    def delete_bucket(bucket_name, options={})
      resp = delete(bucket_name, '/', options)
      if resp.code == "204"
        resp_obj = {}
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = "Bucket deleted"
      else
        resp_obj = Crack::XML.parse(resp.body)
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj["Error"]["Message"].to_s if resp_obj["Error"]["Message"]
        resp_obj[:code] = resp_obj["Error"]["Code"] if resp_obj["Error"]["Code"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :contents, :code, :raw].include?(key) }
      end

      return resp_obj
    end

    ###
    #
    # <b>Returns the Website Configuration currently applied to the specified bucket</b>
    #
    # Google Ref: https://developers.google.com/storage/docs/website-configuration
    #
    # Example:
    #
    #   client.get_webcfg('bucket_name')
    #
    ###

    def get_webcfg(bucket_name, options={})
      resp = get(nil, "/#{bucket_name}?websiteConfig", options)
      resp_obj = {}
      resp_obj[:raw] = Crack::XML.parse(resp.body) if resp.body
      if resp.code == "200"
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:config] = resp_obj[:raw]['WebsiteConfiguration']
        resp_obj[:message] = "Website configuration retrieved"
      else
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj[:raw]["Error"]["Message"].to_s if resp_obj[:raw]["Error"]["Message"]
        resp_obj[:code] = resp_obj[:raw]["Error"]["Code"] if resp_obj[:raw]["Error"]["Code"]
      end

      resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :config, :message, :code, :raw].include?(key) }

      return resp_obj
    end

    ###
    #
    # <b>Sets the Website Configuration on the specified bucket</b>
    #
    # Google Ref: https://developers.google.com/storage/docs/website-configuration
    #
    # Example:
    #
    #   client.set_webcfg('bucket_name', {
    #     'MainPageSuffix' => 'index.html',
    #     'NotFoundPage' => '404.html'
    #   })
    #
    ###

    def set_webcfg(bucket_name, webcfg, options={})
      # Prepare XML
      options[:data] = '<WebsiteConfiguration>'
      webcfg.each do |key, val|
        options[:data] << "<#{key}>#{val}</#{key}>"
      end if webcfg.respond_to?(:each)
      options[:data] << '</WebsiteConfiguration>'
      # Make the request
      resp = put(nil, "/#{bucket_name}?websiteConfig", options)
      if resp.code == "200"
        resp_obj = {}
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = "Website Configuration successful"
      else
        resp_obj = Crack::XML.parse(resp.body)
        resp_obj[:success] = false
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = resp_obj["Error"]["Message"].to_s if resp_obj["Error"]["Message"]
        resp_obj[:code] = resp_obj["Error"]["Code"] if resp_obj["Error"]["Code"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless [:success, :bucket_name, :message, :code, :raw].include?(key) }
      end
      return resp_obj
    end

  end
end