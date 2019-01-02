efs_root = "/efs"

if !Dir.exists?("#{efs_root}")

  apt_package "nfs-common" do
    action :install
  end

  directory "#{efs_root}" do
    action :create
    recursive true
  end

  execute "mount-efs" do
    command "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport #{node['efs_mount']}:/ /efs"
  end

end
