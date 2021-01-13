user = 'ubuntu'

db = search("aws_opsworks_rds_db_instance").first

search("aws_opsworks_app").each do |app|

  if app['deploy']

    domains = app['domains'].join(" ")
    protocol = app['enable_ssl'] ? ('https') : ('http');
    wp_home =  "#{protocol}://#{app['domains'].first}";
    site_url = "#{wp_home}/wp"
    site_root = "/var/www/#{app['shortname']}/"
    shared_dir = "/efs/#{app['shortname']}/shared/"
    current_link = "#{site_root}current"
    time =  Time.new.strftime("%Y%m%d%H%M%S")
    release_dir = "#{site_root}releases/#{time}/"
    theme_dir = "#{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/"
    app_db = app['data_sources'].first

    count_command = "ls -l #{site_root}releases/ | grep ^d | wc -l"
    directory_count = shell_out(count_command)

    if directory_count.stdout.to_i > 3
      execute "delete-oldest-release" do
        command "find #{site_root}releases/* -maxdepth 0 -type d -print | sort | head -n 1 | xargs rm -rf"
      end
    end

    directory "#{release_dir}" do
      owner "www-data"
      group "www-data"
      mode "2775"
      action :create
      recursive true
    end

    file "/home/#{user}/.ssh/id_rsa" do
      content "#{app['app_source']['ssh_key']}"
      owner "#{user}"
      group "opsworks"
      mode 00400
      action [:delete, :create]
    end

    execute "ssh-git-clone" do
      command "ssh-agent sh -c 'ssh-add /home/#{user}/.ssh/id_rsa; git clone -b #{app['app_source']['revision']} --single-branch #{app['app_source']['url']} #{release_dir}'"
    end

    directory "#{release_dir}web/app/uploads" do
      recursive true
      action :delete
    end

    link "#{release_dir}web/app/uploads" do
      to "#{shared_dir}web/app/uploads"
    end

    template "#{release_dir}.env" do
      source "env.erb"
      mode "0644"
      group "www-data"
      owner "www-data"
      action [:delete, :create]

      variables(
        :db_name          =>  "#{app_db['database_name']}",
        :db_host          =>  "#{db['address']}",
        :db_user          =>  "#{db['db_user']}",
        :db_password      =>  "#{db['db_password']}",
        :wp_env           =>  "#{app['environment']['WP_ENV']}",
        :wp_home          =>  "#{wp_home}",
        :wp_siteurl       =>  "#{site_url}",
        :nav_apiurl       =>  "#{app['environment']['NAV_APIURL']}",
        :nav_user         =>  "#{app['environment']['NAV_USER']}",
        :nav_password     =>  "#{app['environment']['NAV_PASSWORD']}",
        :torggler_es_host =>  "#{app['environment']['TORGGLER_ES_HOST']}",
        :torggler_es_index => "#{app['environment']['TORGGLER_ES_INDEX']}",
        :auth_key         =>  "#{app['environment']['AUTH_KEY']}",
        :secure_auth_key  =>  "#{app['environment']['SECURE_AUTH_KEY']}",
        :logged_in_key    =>  "#{app['environment']['LOGGED_IN_KEY']}",
        :nonce_key        =>  "#{app['environment']['NONCE_KEY']}",
        :auth_salt        =>  "#{app['environment']['AUTH_SALT']}",
        :secure_auth_salt =>  "#{app['environment']['SECURE_AUTH_SALT']}",
        :logged_in_salt   =>  "#{app['environment']['LOGGED_IN_SALT']}",
        :nonce_salt       =>  "#{app['environment']['NONCE_SALT']}"
      )
    end

    execute "run-composer" do
      command "composer install -d #{release_dir}"
    end

    execute "theme-build-composer" do
      cwd "#{theme_dir}"
      command "composer update"
      only_if { File.exists?("#{theme_dir}composer.json") }
    end

    execute "change-ownership" do
      command "chown -R #{user}:www-data #{theme_dir}"
    end

    execute "npm-install" do
      user "#{user}"
      group "www-data"
      environment ({
        'HOME' => "/home/#{user}",
        'USER' => "#{user}"
      })
      command "npm --prefix #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/ install #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/"
    end

    execute "theme-build" do
      user "#{user}"
      group "www-data"
      cwd "#{theme_dir}"
      command "npm run build:production"
      only_if { File.exists?("#{theme_dir}package.json") }
    end

    execute "change-ownership" do
      command "chown -R www-data:www-data #{release_dir}"
    end

    execute "change-directory-permissions" do
      command "find #{release_dir} -type d -exec chmod 2775 {} +"
    end

    execute "change-file-permissions" do
      command "find #{release_dir} -type f -exec chmod 0664 {} +"
    end

    template "/etc/nginx/sites-available/nginx-#{app['shortname']}.conf" do
      source "nginx-wordpress.conf.erb"
      owner "root"
      group "www-data"
      mode "640"
      notifies :run, "execute[check-nginx]"
      variables(
        :web_root => "#{site_root}current/web",
        :domains => domains,
        :app_name => app['shortname'],
        :enable_ssl => app['enable_ssl'],
        :php_timeout => app['environment']['PHP_TIMEOUT']
      )
    end

    link "/etc/nginx/sites-enabled/nginx-#{app['shortname']}.conf" do
      to "/etc/nginx/sites-available/nginx-#{app['shortname']}.conf"
    end

    execute "check-nginx" do
      command "nginx -t"
      action :nothing
    end

    link "#{current_link}" do
      action :delete
    end

    link "#{current_link}" do
      to "#{release_dir}"
      notifies :run, "execute[reload-nginx-php]"
    end

    execute "reload-nginx-php" do
      command "nginx -t && service nginx reload && service php7.0-fpm restart"
      action :nothing
    end

  end

end
