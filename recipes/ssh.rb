#
# Cookbook Name:: cygwin
# Recipe:: ssh
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
#

# Install and configure SSH server




# FIXME: make this a definition?
#  WARNING: cut-n-paste programming here... NOOOOOOOOO!
if node['cygwin']['proxy'].nil?
    proxycmd  = ""
else
    proxycmd  = "--proxy #{node['cygwin']['proxy']}"
end
# FIXME: definition!!
execute "setup-more-packages.exe" do
    # FIXME: don't do this everytime...
    #not_if {File.exists?("/etc/passwd")}
    cwd node['cygwin']['download_path'] 
    command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd} -P openssh"
    action :run
end
