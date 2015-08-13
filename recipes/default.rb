#
# Cookbook Name:: desktop
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# apt
include_recipe 'desktop::apt'

# Hardware.
include_recipe 'desktop::pc-speaker'
include_recipe 'desktop::bluetooth'

package 'pciutils'

# Don't configure nvidia drivers on non-nvidia systems.
if system('lspci | grep VGA | grep -i nvidia') 
  include_recipe 'desktop::nvidia'
else
  log 'This system does not contain an nVidia GPU'
  file '/etc/X11/xorg.conf.d/20-nvidia.conf' do
    action :delete
  end
  package 'xserver-xorg'
end

# Software.
include_recipe 'desktop::applications'

# Primary user configuration -- see attributes/user.rb!
include_recipe 'desktop::user'

