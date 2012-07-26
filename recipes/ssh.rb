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


if node['cygwin']['sshd_passwd'].nil? 
    raise "No password defined for the sshd privileged users (#{}): you MUST define one in your attributes! (node['cygwin']['sshd_passwd'])"
end

# Only execute if sshd is NOT already running
require 'win32ole'
wmi = WIN32OLE.connect("winmgmts://")
processes = wmi.ExecQuery("select * from win32_process where Name = 'sshd.exe' ")
total = 0
processes.each do
 total+=1 
end

if total < 1 

    # Install packages
    packages = %w( openssh cygrunsrv )

    ##  WARNING: cut-n-paste programming here... NOOOOOOOOO!
    ## FIXME: make this a definition?
    if node['cygwin']['proxy'].nil?
        proxycmd  = ""
    else
        proxycmd  = "--proxy #{node['cygwin']['proxy']}"
    end
    execute "setup-more-packages.exe" do
        # FIXME: don't do this everytime...
        #not_if {File.exists?("/etc/passwd")}
        cwd node['cygwin']['download_path'] 
        command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd} -P #{packages.join ','}"
        action :run
    end


    ## Configure sshd service
    execute "ssh-host-config" do
        #not_if sshd process is running ; done
        cwd 'c:\cygwin\bin' # Get bash in our path!
        environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
        # warning: respect password complexity requirements!
        command "bash /usr/bin/ssh-host-config --yes --cygwin \"ntsec\" --user #{node['cygwin']['sshd_user']} --pwd r\"#{node['cygwin']['sshd_passwd']}\" "
    end

    # Start the service
    execute "cygrunsrv" do
        cwd 'c:\cygwin\bin' 
        environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
        command 'cygrunsrv -S sshd'
    end

else
    log("Skipped sshd installation: sshd.exe already running"){ level :info }
end
