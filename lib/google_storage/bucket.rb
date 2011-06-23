
module GoogleStorage
  class Client

    def list_buckets(options={})
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

    def list_acls_for_bucket(bucket, options={})
      resp = get(bucket, '/?acl', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp_obj["AccessControlList"]
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket
        resp_obj[:acl] = resp_obj["AccessControlList"]
        resp_obj[:raw] = Crack::XML.parse(resp.body)
        resp_obj.each_key {|key| resp_obj.delete(key) unless key == :success || key == :bucket_name || key == :acl || key == :raw }
      end
      return resp_obj
    end

    alias :bucket_acls :list_acls_for_bucket

    def create_bucket(bucket, options={})
      options[:send_goog_project_id] = true
      resp = put(bucket, '/', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp.code == "200"
        resp_obj.clear
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket
        resp_obj[:message] = "Bucket created"
      end
      return resp_obj
    end

    def get_bucket(bucket, options={})
      resp = get(bucket, '/', options)
      resp_obj = Crack::XML.parse(resp.body)
      if resp.code == "200"
        resp_obj[:success] = true
        resp_obj[:bucket_name] = bucket
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

    alias :bucket_contents :get_bucket

    def delete_bucket(bucket, options={})
      resp = delete(bucket, '/', options)
      return Crack::XML.parse(resp.body) unless resp.code == "204"
      resp_obj = {}
      resp_obj[:success] = true
      resp_obj[:bucket_name] = bucket
      resp_obj[:message] = "Bucket deleted"
      return resp_obj
    end

  end
end