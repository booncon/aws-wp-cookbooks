efs_root = "/efs"

if !Dir.exists?("#{efs_root}")

  apt_package "nfs-common" do
    action :install
  end

  execute "mount-efs" do
    command "sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s #{node['efs_mount']}:/ efs"
  end

  directory "#{efs_root}" do
    action :create
    recursive true
  end

end
