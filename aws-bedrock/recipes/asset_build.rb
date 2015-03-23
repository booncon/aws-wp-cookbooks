composer_package "#{deploy[:deploy_to]}/current" do
  action :install
  dev true
end