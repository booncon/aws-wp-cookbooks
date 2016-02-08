db = search("aws_opsworks_rds_db_instance").first
app = search("aws_opsworks_app").first
app_db = app['data_sources'].first

envfile = "#{node['phpapp']['path']}.env"

template "#{envfile}" do
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
    :wp_home          =>  "#{app['environment']['WP_HOME']}",
    :wp_siteurl       =>  "#{app['environment']['WP_SITEURL']}",
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
