#
# Cookbook Name:: cygwin
# Recipe:: default
#
# Copyright 2012, La Presse
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

directory node['cygwin']['download_path'] do
  recursive true
end

remote_file "#{node['cygwin']['download_path']}/setup.exe" do
  source 'http://cygwin.com/setup-x86_64.exe'
  action :create_if_missing
end

if Chef::Config['http_proxy'].nil?
  proxycmd  = ""
else
  proxycmd  = "--proxy #{Chef::Config['http_proxy']}"
end

execute "setup.exe" do
  cwd node['cygwin']['download_path']
  command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd}"
  not_if {File.exists?("c:/cygwin/etc/passwd")}
end

windows_path "#{node['cygwin']['home']}/bin".gsub( /\//, "\\") do
  action :add
end
