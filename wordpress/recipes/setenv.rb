db = search("aws_opsworks_rds_db_instance").first
app = search("aws_opsworks_app").first

execute "set-db-name" do
  command "echo 'env[DB_NAME] = #{app['data_sources']['database_name']}' >> /etc/php5/fpm/pool.d/www.conf"
end

execute "set-db-host" do
  command "echo 'env[DB_HOST] = #{db['address']}' >> /etc/php5/fpm/pool.d/www.conf"
end

execute "set-db-user" do
  command "echo 'env[DB_USER] = #{db['db_user']}' >> /etc/php5/fpm/pool.d/www.conf"
end

execute "set-db-password" do
  command "echo 'env[DB_PASSWORD] = #{db['db_password']}' >> /etc/php5/fpm/pool.d/www.conf"
end
