db = search("aws_opsworks_rds_db_instance").first
app = search("aws_opsworks_app").first

execute "set-db-name" do
  command "export DB_NAME = #{app['data_sources']['database_name']}"
end

execute "set-db-host" do
  command "export DB_HOST = #{db['address']}"
end

execute "set-db-user" do
  command "export DB_USER = #{db['db_user']}"
end

execute "set-db-password" do
  command "export DB_PASSWORD = #{db['db_password']}"
end
