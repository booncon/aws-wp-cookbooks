user = 'ubuntu'

site_root = "#{node['web_root']}#{app['environment']['THEME_NAME']}/"
shared_dir = "#{site_root}shared/"
shared_source = "/efs/torgglercommerz/shared/"

if !Dir.exists?("#{site_root}")
  apt_package "nginx-extras" do
    action :install
  end

  apt_package "zip" do
    action :install
  end

  apt_package "subversion" do
    action :install
  end

  apt_package "php7.0-fpm" do
    action :install
  end

  apt_package "php7.0-cli" do
    action :install
  end

  apt_package "php7.0-xml" do
    action :install
  end

  apt_package "php7.0-mbstring" do
    action :install
  end

  apt_package "php7.0-mysql" do
    action :install
  end

  apt_package "npm" do
    action :install
  end

  execute "ssh-keyscan" do
    command "ssh-keyscan github.com >> ~/.ssh/known_hosts"
  end

  execute "add-user-to-group" do
    command "sudo usermod -a -G www-data #{user}"
  end

  template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    owner "root"
    group "www-data"
    mode "640"
    notifies :run, "execute[reload-nginx]"
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

  execute "npm-gulp" do
    command "npm install -g gulp"
  end

  execute "npm-bower" do
    command "npm install -g bower"
  end

  link "/usr/bin/node" do
    to "/usr/bin/nodejs"
  end
end
