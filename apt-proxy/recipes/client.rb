#
# Cookbook Name:: apt-proxy
# Recipe:: client
#
# Copyright 2008, OpsCode, Inc.
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

# try to find the first apt_proxy server in our search index of available chef nodes
results = search(:node, "recipe:apt-proxy::server")
if results && !results.empty?
  apt_proxy_server = results.first["fqdn"]
else
  Chef::Log.warn("Could not find any nodes with the apt-proxy::server recipe.")
end

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  variables :server => apt_proxy_server, :code_name => node[:lsb][:codename]
  owner "root"
  group "root"
  mode "644"
end

include_recipe "apt"