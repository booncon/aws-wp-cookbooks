efs_root = "/efs"

if !Dir.exists?("#{efs_root}")

  execute "install-nfs-common" do
    command "sudo apt-get install nfs-common"
  end

  directory "#{efs_root}" do
    action :create
    recursive true
  end

  execute "mount-efs" do
    command "sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s #{node['efs_mount']}:/ efs"
  end

end
