### Configuration ###
#
#   require "google_storage"
#
#   The following will look for google_storage.yml in your rails config directory
#     gs_client = GoogleStorage::Client.new
#
#   Otherwise you can pass in the path to the google_storage.yml
#     gs_client = GoogleStorage::Client.new(:config_yml => 'C:/example_path/google_storage.yml')
#
### Service Requests ###
#
#   GET Service
#     gs_client.list_buckets
#
### Bucket Requests ###
#
#   GET Access Control List for Bucket
#     gs_client.list_acls_for_bucket('bucket_name')
#     gs_client.bucket_acls('bucket_name')
#
#   PUT Bucket
#     gs_client.create_bucket('bucket_name')                                <-- private bucket
#     gs_client.create_bucket('bucket_name', :x_goog_acl => 'public-read')  <-- public bucket
#
#   GET Bucket
#     gs_client.get_bucket('bucket_name')
#     gs_client.bucket_contents('bucket_name')
#
#   DELETE Bucket
#     gs_client.delete_bucket('bucket_name')
#
### Object Requests ###
#
#   GET Access Control List for Object
#     gs_client.list_acls_for_object('bucket_name', 'object_name')
#     gs_client.object_acls('bucket_name', 'object_name')
#
#   GET Object
#     gs_client.get_object('bucket_name', 'object_name')
#     gs_client.get_object('bucket_name', 'object_name', :write_to_file => '/tmp/example/file.jpg')
#
#   POST Object
#    !!!! NOT ADDING POST METHOD AT THIS STAGE AS REQUIRES USE OF API V1 USING LEGACY ACCESS KEY
#    !!!! USE PUT METHOD INSTEAD TO UPLOAD FILES
#
#   PUT Object
#     gs_client.put_object('bucket_name', 'object_name', :data => File.read('/tmp/example/file.jpg'), :x_goog_acl => 'public-read')
#     gs_client.put_object('bucket_name', 'object_name', :path_to_file => '/tmp/example/file.jpg')
#
#   HEAD Object
#     gs_client.head_object('bucket_name', 'object_name')
#
#   DELETE Object
#     gs_client.delete_object('bucket_name', 'object_name')





