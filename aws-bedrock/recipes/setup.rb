require 'uri'
require 'net/http'
require 'net/https'

uri = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
keys = response.body

keys = keys.gsub(/', +'/, "='")
keys = keys.gsub(/define\('/, "")
keys = keys.gsub(/'\);/, "'")

node[:deploy].each do |app_name, deploy|

  # create .env file with all the environment variables
  Chef::Log.debug("Setting up Wordpress .env file...")
  template "#{node[:symlink_path]}/.env" do
        source "env.erb"
        mode 0660
        group deploy[:group]

        if platform?("ubuntu")
          owner "www-data"
        elsif platform?("amazon")
          owner "apache"
        end

        variables(
            :database   => (deploy[:database][:database] rescue nil),
            :user       => (deploy[:database][:username] rescue nil),
            :password   => (deploy[:database][:password] rescue nil),
            :host       => (deploy[:database][:host] rescue nil),
            :protocol   => (deploy[:ssl_certificate] != nil ? 'https://' : 'http://'),
            :domain     => (deploy[:domains][0] rescue nil),
            :stage     => (deploy[:environment_variables][:stage] rescue nil),
            :keys       => (keys rescue nil)
        )
    end

end  