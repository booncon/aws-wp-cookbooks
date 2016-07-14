user = 'ubuntu'

healthcheck_root = "#{node['web_root']}healthcheck/"

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

  template "/etc/nginx/sites-available/nginx-healthcheck.conf" do
    source "nginx-healthcheck.conf.erb"
    owner "root"
    group "www-data"
    mode "640"
    notifies :run, "execute[reload-nginx]"
    variables(
      :web_root => "#{site_root}/healthcheck"
    )
  end

  link "/etc/nginx/sites-enabled/nginx-healthcheck.conf" do
    to "/etc/nginx/sites-available/nginx-healthcheck.conf"
  end

  directory "#{healthcheck_root}" do
    owner "www-data"
    group "www-data"
    mode "2775"
    action :create
    recursive true
  end

  template "#{site_root}/healthcheck/index.html" do
    source "healthcheck.html.erb"
    owner "root"
    group "www-data"
    mode "640"
  end

  execute "reload-nginx" do
    command "nginx -t && service nginx reload"
    action :nothing
  end

end
