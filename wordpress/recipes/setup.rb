user = 'ubuntu'
healthcheck_root = "/var/www/healthcheck/"

if !Dir.exists?("#{healthcheck_root}")

  execute "add-user-to-group" do
    command "sudo usermod -a -G www-data #{user}"
  end

  apt_package "nginx-extras" do
    action :install
  end

  apt_package "zip" do
    action :install
  end

  apt_package "subversion" do
    action :install
  end

  apt_package "htop" do
    action :install
  end

  apt_package "php-fpm" do
    action :install
  end

  apt_package "php-cli" do
    action :install
  end

  apt_package "php-xml" do
    action :install
  end

  apt_package "php-mbstring" do
    action :install
  end

  apt_package "php-mysql" do
    action :install
  end

  apt_package "php-soap" do
    action :install
  end

  apt_package "php-curl" do
    action :install
  end

  apt_package "php-apcu" do
    action :install
  end
  
  apt_package "php-imagick" do
    action :install
  end
  
  apt_package "php-gd" do
    action :install
  end

  apt_package "npm" do
    action :install
  end

  execute "ssh-keyscan" do
    command "ssh-keyscan github.com >> ~/.ssh/known_hosts"
  end

  execute "install-composer" do
    command "curl -sS https://getcomposer.org/installer | php"
  end

  execute "install-composer-globally" do
    command "mv composer.phar /usr/local/bin/composer"
  end

  execute "install-wpcli" do
    command "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
  end

  execute "install-wpcli-globally" do
    command "chmod +x wp-cli.phar; mv wp-cli.phar /usr/local/bin/wp"
  end

  execute "npm-gulp" do
    command "npm install -g gulp"
  end

  execute "npm-bower" do
    command "npm install -g bower"
  end

  execute "npm-webpack" do
    command "npm install -g webpack"
  end

  directory "#{healthcheck_root}" do
    owner "www-data"
    group "www-data"
    mode "2775"
    action :create
    recursive true
  end

  template "#{healthcheck_root}/index.html" do
    source "healthcheck.html.erb"
    owner "root"
    group "www-data"
    mode "640"
  end

  template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    owner "root"
    group "www-data"
    mode "640"
    notifies :run, "execute[restart-nginx]"
  end

  file "/etc/nginx/sites-enabled/default" do
    action :delete
    manage_symlink_source true
    only_if "test -f /etc/nginx/sites-enabled/default"
  end

  template "/etc/nginx/sites-available/nginx-healthcheck.conf" do
    source "nginx-healthcheck.conf.erb"
    owner "root"
    group "www-data"
    mode "640"
    notifies :run, "execute[restart-nginx]"
    variables(
      :web_root => "#{healthcheck_root}"
    )
  end

  link "/etc/nginx/sites-enabled/nginx-healthcheck.conf" do
    to "/etc/nginx/sites-available/nginx-healthcheck.conf"
  end

  execute "restart-nginx" do
    command "nginx -t && service nginx restart"
    action :nothing
  end

end
