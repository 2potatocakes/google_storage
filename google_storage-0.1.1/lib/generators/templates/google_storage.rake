require 'google_storage'

namespace :gs do
  client = GoogleStorage::Client.new

  namespace :grant do
    desc "Google Storage URL to grant 'read only' access to your storage account"
    task :read_only do
      puts client.authorization_url(:read_only)
    end

    desc "Google Storage URL to grant 'read/write' access to your storage account"
    task :read_write do
      puts client.authorization_url(:read_write)
    end

    desc "Google Storage URL to grant 'read only' access to your storage account"
    task :full_control do
      puts client.authorization_url(:full_control)
    end
  end

  desc "Acquire Google Storage refresh token"
  task :refresh_token, :auth_code do |t, args|
    puts "refresh_token: #{client.acquire_refresh_token(args[:auth_code])}"
  end
end