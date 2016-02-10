app = search("aws_opsworks_app").first
user = search("aws_opsworks_user").first

site_root = "#{node['web_root']}#{app['environment']['THEME_NAME']}/"
current_link = "#{site_root}current"
time =  Time.new.strftime("%Y%m%d%H%M%S")
release_dir = "#{site_root}releases/#{time}/"
shared_upload_dir = "#{site_root}shared/web/app/uploads/"

apt_package "nginx-extras" do
  action :install
end

apt_package "php5-fpm" do
  action :install
end

apt_package "php5-cli" do
  action :install
end

apt_package "php5-mysql" do
  action :install
end

apt_package "npm" do
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

directory "#{site_root}" do
  owner "www-data"
  group "www-data"
  mode "2775"
  action :create
  recursive true
end

directory "#{release_dir}" do
  owner "www-data"
  group "www-data"
  mode "2775"
  action :create
  recursive true
end

directory "#{shared_upload_dir}" do
  owner "www-data"
  group "www-data"
  mode "2777"
  action :create
  recursive true
end

execute "ssh-git-clone" do
  command "ssh-agent sh -c 'ssh-add /home/#{user['username']}/.ssh/id_rsa; git clone #{app['app_source']['url']} #{release_dir}'"
end

link "#{current_link}" do
  to "#{release_dir}"
end

link "#{release_dir}web/app/uploads" do
  to "#{shared_upload_dir}"
end

link "#{release_dir}.env" do
  to "#{site_root}shared/.env"
end

execute "change-directory-permissions" do
  command "find #{site_root} -type d -exec chmod 2775 {} +"
end

execute "change-file-permissions" do
  command "find #{site_root} -type f -exec chmod 0664 {} +"
end

execute "change-ownership" do
  command "chown -R www-data:www-data #{site_root}"
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

execute "install-composer" do
  command "curl -sS https://getcomposer.org/installer | php"
end

execute "install-composer-globally" do
  command "mv composer.phar /usr/local/bin/composer"
end

execute "run-composer" do
  command "composer install -d #{release_dir}"
end

execute "npm-install" do
  command "npm --prefix #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/ install #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/"
end

execute "npm-gulp" do
  command "npm install -g gulp"
end

execute "npm-grunt" do
  command "npm install -g grunt"
end

execute "npm-bower" do
  command "npm install -g bower"
end
