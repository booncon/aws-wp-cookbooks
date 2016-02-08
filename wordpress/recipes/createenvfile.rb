db = search("aws_opsworks_rds_db_instance").first
app = search("aws_opsworks_app").first

envfile = "#{node['phpapp']['path']}.env"

file "#{envfile}" do
  owner "www-data"
  group "www-data"
  mode "0644"
  action [:delete, :create]
end

execute "set-db-name" do
  app_db = app['data_sources'].first
  command "echo DB_NAME=#{app_db['database_name']} >> #{envfile}"
end

execute "set-db-host" do
  command "echo DB_HOST=#{db['address']} >> #{envfile}"
end

execute "set-db-user" do
  command "echo DB_USER=#{db['db_user']} >> #{envfile}"
end

execute "set-db-password" do
  command "echo DB_PASSWORD=#{db['db_password']} >> #{envfile}"
end

execute "set-wp-env" do
  command "echo WP_ENV=#{app['environment']['WP_ENV']} >> #{envfile}"
end

execute "set-wp-home" do
  command "echo WP_HOME=#{app['environment']['WP_HOME']} >> #{envfile}"
end

execute "set-wp-siteurl" do
  command "echo WP_SITEURL=#{app['environment']['WP_SITEURL']} >> #{envfile}"
end

execute "set-auth-key" do
  command "echo AUTH_KEY='#{app['environment']['AUTH_KEY']}' >> #{envfile}"
end

execute "set-secure-auth-key" do
  command "echo SECURE_AUTH_KEY='#{app['environment']['SECURE_AUTH_KEY']}' >> #{envfile}"
end

execute "set-logged-in-key" do
  command "echo LOGGED_IN_KEY='#{app['environment']['LOGGED_IN_KEY']}' >> #{envfile}"
end

execute "set-nonce-key" do
  command "echo NONCE_KEY='#{app['environment']['NONCE_KEY']}' >> #{envfile}"
end

execute "set-auth-salt" do
  command "echo AUTH_SALT='#{app['environment']['AUTH_SALT']}' >> #{envfile}"
end

execute "set-secure-auth-salt" do
  command "echo SECURE_AUTH_SALT='#{app['environment']['SECURE_AUTH_SALT']}' >> #{envfile}"
end

execute "set-logged-in-salt" do
  command "echo LOGGED_IN_SALT='#{app['environment']['LOGGED_IN_SALT']}' >> #{envfile}"
end

execute "set-nonce-salt" do
  command "echo NONCE_SALT='#{app['environment']['NONCE_SALT']}' >> #{envfile}"
end
