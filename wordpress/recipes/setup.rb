app = search("aws_opsworks_app").first
user = 'ubuntu'

site_root = "#{node['web_root']}#{app['environment']['THEME_NAME']}/"
current_link = "#{site_root}current"
time =  Time.new.strftime("%Y%m%d%H%M%S")
release_dir = "#{site_root}releases/#{time}/"
shared_dir = "#{site_root}shared/"
shared_source = "/efs/torgglercommerz/shared/"

if !Dir.exists?("#{site_root}")
  apt_package "nginx-extras" do
    action :install
  end

  apt_package "php7-fpm" do
    action :install
  end

  apt_package "php7-cli" do
    action :install
  end

  apt_package "php7-mysql" do
    action :install
  end

  apt_package "npm" do
    action :install
  end

  execute "ssh-keyscan" do
    command "ssh-keyscan github.com >> ~/.ssh/known_hosts"
  end

  file "/home/#{user}/.ssh/id_rsa" do
    content "#{app['app_source']['ssh_key']}"
    owner "#{user}"
    group "opsworks"
    mode 00400
    action [:delete, :create]
  end

  directory "#{site_root}" do
    owner "www-data"
    group "www-data"
    mode "2775"
    action :create
    recursive true
  end

  execute "symlink-shared-dir" do
    command "ln -sf #{shared_dir} #{shared_source}"
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
    command "sudo usermod -a -G www-data #{user}"
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

    variables(
      :web_root => "#{app['environment']['THEME_NAME']}"
    )
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
