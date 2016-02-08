db = search("aws_opsworks_rds_db_instance").first
app = search("aws_opsworks_app").first

execute "set-db-name" do
  app_db = app['data_sources'].first
  command "echo DB_NAME=#{app_db['database_name']} >> /etc/environment"
end

execute "set-db-host" do
  command "echo DB_HOST=#{db['address']} >> /etc/environment"
end

execute "set-db-user" do
  command "echo DB_USER=#{db['db_user']} >> /etc/environment"
end

execute "set-db-password" do
  command "echo DB_PASSWORD=#{db['db_password']} >> /etc/environment"
end

execute "set-wp-env" do
  "command echo WP_ENV=#{app['environment']['WP_ENV']} >> /etc/environment"
end

execute "set-wp-home" do
  "command echo WP_HOME=#{app['environment']['WP_HOME']} >> /etc/environment"
end

execute "set-wp-siteurl" do
  "command echo WP_SITEURL=#{app['environment']['WP_SITEURL']} >> /etc/environment"
end

execute "set-auth-key" do
  "command echo AUTH_KEY='#{app['environment']['AUTH_KEY']}' >> /etc/environment"
end

execute "set-secure-auth-key" do
  "command echo SECURE_AUTH_KEY='#{app['environment']['SECURE_AUTH_KEY']}' >> /etc/environment"
end

execute "set-logged-in-key" do
  "command echo LOGGED_IN_KEY='#{app['environment']['LOGGED_IN_KEY']}' >> /etc/environment"
end

execute "set-nonce-key" do
  "command echo NONCE_KEY='#{app['environment']['NONCE_KEY']}' >> /etc/environment"
end

execute "set-auth-salt" do
  "command echo AUTH_SALT='#{app['environment']['AUTH_SALT']}' >> /etc/environment"
end

execute "set-secure-auth-salt" do
  "command echo SECURE_AUTH_SALT='#{app['environment']['SECURE_AUTH_SALT']}' >> /etc/environment"
end

execute "set-logged-in-salt" do
  "command echo LOGGED_IN_SALT='#{app['environment']['LOGGED_IN_SALT']}' >> /etc/environment"
end

execute "set-nonce-salt" do
  "command echo NONCE_SALT='#{app['environment']['NONCE_SALT']}' >> /etc/environment"
end
