### Configuration ###
#
#   require "google_storage"
#
#   The following will look for google_storage.yml in your rails config directory
#     client = GoogleStorage::Client.new
#
#   Otherwise you can pass in the path to the google_storage.yml
#     client = GoogleStorage::Client.new(:config_yml => 'C:/example_path/config/google_storage.yml')
#
### Service Requests ###
#
#   GET Service
#     client.list_buckets
#
### Bucket Requests ###
#
#   GET Access Control List for Bucket
#     client.bucket_acls('bucket_name')
#
#   PUT Bucket
#     client.create_bucket('bucket_name')                                <-- private bucket
#     client.create_bucket('bucket_name', :x_goog_acl => 'public-read')  <-- public bucket
#
#   GET Bucket
#     client.get_bucket('bucket_name')
#
#   DELETE Bucket
#     client.delete_bucket('bucket_name')
#
### Object Requests ###
#
#   GET Access Control List for Object
#     client.object_acls('bucket_name', 'filename.jpg')
#
#   GET Object
#     client.get_object('bucket_name', 'filename.jpg')
#     client.get_object('bucket_name', 'filename.jpg', :write_to_file => 'c:/temp/new_file_name.jpg')
#
#   POST Object
#    !!!! NOT ADDING POST METHOD AT THIS STAGE AS REQUIRES USE OF API V1 USING LEGACY ACCESS KEY
#    !!!! USE PUT METHOD INSTEAD TO UPLOAD FILES
#
#   PUT Object
#     client.put_object('bucket_name', 'filename.jpg', :data => File.read('c:/temp/file.jpg'), :x_goog_acl => 'public-read')
#     client.upload_object('bucket_name', 'filename.jpg', :path_to_file => 'c:/temp/file.jpg')
#
#   HEAD Object
#     client.object_head('bucket_name', 'filename.jpg')
#
#   DELETE Object
#     client.delete_object('bucket_name', 'filename.jpg')





