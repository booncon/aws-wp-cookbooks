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
