node[:deploy].each do |app_name, deploy|

  composer_package "#{deploy[:deploy_to]}/current" do
    action :install
    dev true
  end

end  