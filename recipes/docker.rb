#
# Cookbook Name:: desktop
# Recipe:: docker
#
# Copyright 2015 Andrew Jones
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'desktop::backports'

package 'dirmngr'

package 'apt-transport-https' do
  action :upgrade
end

apt_repository 'docker' do
  uri 'https://apt.dockerproject.org/repo'
  distribution "#{node[:lsb][:id]}-#{node[:lsb][:codename]}".downcase
  components ['main']
  keyserver 'hkps.pool.sks-keyservers.net'
  key '58118E89F3A912897C070ADBF76221572C52609D'
end

apt_package 'docker.io' do
  action :purge
end

ruby_block 'purge-aufs-warning' do
  block do
    if ::File.directory?('/var/lib/docker/aufs')
      raise "Please rm -rf /var/lib/docker/aufs before upgrade.\n" \
            'WARNING: This will delete all of your existing docker containers!'
    end
  end
end

docker_service = 'docker'

apt_package 'docker-engine' do
  action :upgrade
  notifies :restart, "service[#{docker_service}]", :immediately
end

template '/etc/default/docker.io' do
  mode 0444
  source 'docker/docker.io-defaults.erb'
  notifies :restart, "service[#{docker_service}]", :immediately
end

service docker_service do
  action [:enable, :start]
end
