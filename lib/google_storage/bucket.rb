
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
        resp_obj[:buckets] = resp_obj["ListAllMyBucketsResult"]["Buckets"]["Bucket"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless key == :success || key == :buckets || key == :raw }
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
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:acl] = resp_obj["AccessControlList"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless key == :success || key == :bucket_name || key == :acl || key == :raw }
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
      resp_obj = Crack::XML.parse(resp.body)
      if resp.code == "200"
        resp_obj.clear
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket_name
        resp_obj[:message] = "Bucket created"
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
        contents = resp_obj["ListBucketResult"]["Contents"] ? Array.new : nil
        resp_obj["ListBucketResult"]["Contents"].is_a?(Array) ? \
          (contents = resp_obj["ListBucketResult"]["Contents"]) : \
          (contents[0] = resp_obj["ListBucketResult"]["Contents"]) unless contents.nil?
        resp_obj[:contents] = contents
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless key == :success || key == :bucket_name || key == :contents || key == :raw  }
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
      return Crack::XML.parse(resp.body) unless resp.code == "204"
      resp_obj = {}
      resp_obj[:success] = true
      resp_obj[:bucket_name] = bucket_name
      resp_obj[:message] = "Bucket deleted"
      return resp_obj
    end

  end
end