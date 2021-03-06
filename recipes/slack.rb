#
# Cookbook Name:: desktop
# Recipe:: slack
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

include_recipe 'apt'
include_recipe 'desktop::libgcrypt11'

package [ 
         'gconf2', 
         'gconf-service', 
         'libgtk2.0-0', 
         'libudev1', 
         'libgcrypt11',
         'libnotify4', 
         'libxtst6', 
         'libnss3', 
         'python', 
         'gvfs-bin', 
         'xdg-utils',
         'apt-transport-https',
         'libgnome-keyring0',
        ] do
  action :upgrade
end

#
# Slack doesn't have official Ubuntu/Trusty repos, so we'll use the
# Jessie repo everywhere.
#
apt_repository 'slack' do
  components ['main']
  distribution 'jessie'
  key 'https://packagecloud.io/slacktechnologies/slack/gpgkey'
  uri 'https://packagecloud.io/slacktechnologies/slack/debian/'
end

# This was the old name of the file distributed in their package.
file '/etc/apt/sources.list.d/slacktechnologies_slack.list' do
  action :delete
end

package 'slack-desktop' do
  action :upgrade
end
