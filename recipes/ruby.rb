#
# Cookbook Name:: desktop
# Recipe:: ruby
#
# Copyright 2016 Andrew Jones
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

def most_recent_ruby_version
  node[:rbenv][:rubies].map do |version|
    Gem::Version.new(version)
  end.sort.map(&:to_s).last
end

# Install bundler gem in every ruby.
# (Vagrant requires bundler <= 1.10.6)
# see attributes/ruby.rb!
node.default[:rbenv][:gems] = node[:rbenv][:rubies]
  .map { |v| { v => [
                      { 'name' => 'bundler', 'version' => '1.13.6' },
                      { 'name' => 'multipart-post'}
                    ] } }
  .reduce({}, :merge)

include_recipe 'ruby_build'
include_recipe 'ruby_rbenv::system'

Gem::Version
rbenv_global node[:rbenv].fetch(:rbenv_global, most_recent_ruby_version)

unless node[:rbenv].fetch(:keep_old_rubies, false)
  ruby_block 'uninstall-old-rubies' do
    block do
      require 'mixlib/shellout'
      rbenv = node[:rbenv][:root_path] + '/bin/rbenv'

      list_command = Mixlib::ShellOut.new(rbenv,'versions', '--bare')
      list_command.run_command

      raise 'Failed to list ruby versions!' unless list_command.status.success?

      ruby_versions = list_command.stdout.split("\n")
      versions_to_remove =
          ruby_versions.reject{ |v| node[:rbenv][:rubies].include?(v) }

      versions_to_remove.each do |v|
        remove_command = Mixlib::ShellOut.new(rbenv, 'uninstall', '-f', v)
        remove_command.run_command
        raise "Failed to remove ruby #{v}!" unless remove_command.status.success?
      end
    end
  end
end
