#
# Cookbook Name:: bootstrap
# Recipe:: solo
#
# Copyright 2009, Opscode, Inc.
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

root_group = value_for_platform(
  "openbsd" => { "default" => "wheel" },
  "freebsd" => { "default" => "wheel" },
  "default" => "root"
)

gem_package "chef" do
  version node[:bootstrap][:chef][:solo_version]
end

case node[:bootstrap][:chef][:init_style]
when "runit"
  solo_log = node[:bootstrap][:chef][:solo_log]
  show_time  = "false"
  include_recipe "runit"
  runit_service "chef-solo"
when "init"
  solo_log = "\"#{node[:bootstrap][:chef][:solo_log]}\""
  show_time  = "true"

  directory node[:bootstrap][:chef][:run_path] do
    action :create
    owner "root"
    group root_group
    mode "755"
  end

  service "chef-solo" do
    action :nothing
  end

  Chef::Log.info("You specified service style 'init'.")
  Chef::Log.info("'init' scripts available in #{node[:languages][:ruby][:gems_dir]}/gems/chef-#{node[:bootstrap][:chef][:solo_version]}/distro")
when "bsd"
  solo_log = node[:bootstrap][:chef][:solo_log]
  show_time  = "false"
  Chef::Log.info("You specified service style 'bsd'. You will need to set up your rc.local file.")
  Chef::Log.info("Hint: chef-solo -i #{node[:bootstrap][:chef][:solo_interval]} -s #{node[:bootstrap][:chef][:solo_splay]}")
else
  solo_log = node[:bootstrap][:chef][:solo_log]
  show_time  = "false"
  Chef::Log.info("Could not determine service init style, manual intervention required to start up the solo service.")
end

chef_dirs = [
  node[:bootstrap][:chef][:log_dir],
  node[:bootstrap][:chef][:path],
  "/etc/chef"
]

chef_dirs.each do |dir|
  directory dir do
    owner "root"
    group root_group
    mode "755"
  end
end

template "/etc/chef/solo.rb" do
  source "solo.rb.erb"
  owner "root"
  group root_group
  mode "644"
  variables(
    :solo_log => solo_log,
    :show_time  => show_time
  )
end
