app = search("aws_opsworks_app").first
user = search("aws_opsworks_user").first

apt_package "nginx-extras" do
  action :install
end

apt_package "php5-fpm" do
  action :install
end

apt_package "php5-mysql" do
  action :install
end

execute "ssh-keyscan" do
  command "ssh-keyscan github.com >> ~/.ssh/known_hosts"
end

file "/home/#{user['username']}/.ssh/id_rsa" do
  content "#{app['app_source']['ssh_key']}"
  owner "#{user['username']}"
  group "opsworks"
  mode 00600
  action [:delete, :create]
end

directory node["phpapp"]["path"] do
  owner "www-data"
  group "www-data"
  mode "2775"
  action :create
  recursive true
end

execute "ssh-git-clone" do
  command "ssh-agent sh -c 'ssh-add /home/#{user['username']}/.ssh/id_rsa; git clone #{app['app_source']['url']} #{node['phpapp']['path']}'"
end

execute "change-directory-permissions" do
  command "find #{node['phpapp']['path']} -type d -exec chmod 2775 {} +"
end

execute "change-file-permissions" do
  command "find #{node['phpapp']['path']} -type f -exec chmod 0664 {} +"
end

execute "change-ownership" do
  command "chown -R www-data:www-data #{node['phpapp']['path']}"
end

execute "add-user-to-group" do
  command "sudo usermod -a -G www-data #{user['username']}"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "www-data"
  mode "640"
  notifies :run, "execute[reload-nginx]"
end

template "/etc/nginx/sites-available/nginx-wordpress.conf" do
  source "nginx-wordpress.conf.erb"
  owner "root"
  group "www-data"
  mode "640"
  notifies :run, "execute[reload-nginx]"
end

link "/etc/nginx/sites-enabled/nginx-wordpress.conf" do
  to "/etc/nginx/sites-available/nginx-wordpress.conf"
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
  only_if "test -f /etc/nginx/sites-enabled/default"
  notifies :run, "execute[reload-nginx]"
end

execute "reload-nginx" do
  command "nginx -t && service nginx reload"
  action :nothing
end
