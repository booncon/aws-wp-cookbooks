app = search("aws_opsworks_app").first
user = search("aws_opsworks_user").first
app_path = "/srv/#{app['shortname']}"

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
  action :nothing
end

file "/home/#{user['username']}/.ssh/id_rsa" do
  content "#{app['app_source']['ssh_key']}"
  owner "#{user['username']}"
  group "opsworks"
  mode 00644
  action [:delete, :create]
end

git node["phpapp"]["path"] do
  repository "#{app['app_source']['url']}"
  reference "deploy"
  action :sync
  ssh_wrapper "ssh -i /home/#{user['username']}/.ssh/id_rsa"
end

directory node["phpapp"]["path"] do
  owner "www-data"
  group "www-data"
  mode "0755"
  action :create
  recursive true
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
