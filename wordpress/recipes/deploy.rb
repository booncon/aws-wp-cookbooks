user = 'ubuntu'

search("aws_opsworks_app").each do |app|

  if app['deploy']

    site_root = "#{node['web_root']}#{app['shortname']}/"
    shared_dir = "/efs/#{app['shortname']}/shared/"
    current_link = "#{site_root}current"
    time =  Time.new.strftime("%Y%m%d%H%M%S")
    release_dir = "#{site_root}releases/#{time}/"
    theme_dir = "#{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/"

    count_command = "ls -l #{site_root}releases/ | grep ^d | wc -l"
    directory_count = shell_out(count_command)

    if directory_count.stdout.to_i > 4
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

    # link "#{release_dir}.env" do
    #   to "#{shared_dir}.env"
    # end

    # todo -> set up .env

    execute "run-composer" do
      command "composer install -d #{release_dir}"
    end

    execute "npm-install" do
      command "npm --prefix #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/ install #{release_dir}web/app/themes/#{app['environment']['THEME_NAME']}/"
    end

    execute "bower-install" do
      cwd "#{theme_dir}"
      command "bower install --allow-root"
      only_if { File.exists?("#{theme_dir}bower.js") }
    end

    execute "gulp-production" do
      cwd "#{theme_dir}"
      command "gulp --production"
      only_if { File.exists?("#{theme_dir}gulpfile.js") }
    end

    execute "change-directory-permissions" do
      command "find #{release_dir} -type d -exec chmod 2775 {} +"
    end

    execute "change-file-permissions" do
      command "find #{release_dir} -type f -exec chmod 0664 {} +"
    end

    execute "change-ownership" do
      command "chown -R www-data:www-data #{release_dir}"
    end

    link "#{current_link}" do
      action :delete
    end

    link "#{current_link}" do
      to "#{release_dir}"
    end

  end

end
