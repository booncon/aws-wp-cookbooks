name             "aws-bedrock"
maintainer       "booncon"
maintainer_email "luki@booncon.com"
license          "MIT"
description      "Recipe to set up everything for bedrock + composer @ opsworks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
depends          "composer"   

%w{ ubuntu debian centos redhat fedora }.each do |os|
	supports os
end
