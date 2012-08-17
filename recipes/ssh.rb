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
    # Not running, assume it's not installed: 
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



# Sync user/group database
##


#### GIANT FIXME
# See note after

# 1st, for idempotence, we'll dump the results of mkpasswd/mkgroup for comparaison with the actual data
#%w(passwd group).each do |what| 
#    execute "mk#{what}-tmp" do
#        creates "#{Chef::Config[:file_cache_path]}/#{what}"
#        cwd 'c:\cygwin\bin' # Get bash in our path!
#        environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
#        command "bash -c \"/usr/bin/mk#{what} -l > #{node['cygwin']['cygdrive_cache_path']}/#{what}  \" "
#    end
#end

#execute "cygrunsrv-stop" do
##    only_if "bash -c \"/usr/bin/diff #{node['cygwin']['cygdrive_cache_path']}/passwd /etc/passwd \" ",
##        :environment => {'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'}, :cwd => 'c:\cygwin\bin' 
#
#    #&& diff #{node['cygwin']['cygdrive_cache_path']}/group /etc/group"
#    #only_if "bash "diff /cygdrive/c/chef/cache/passwd /etc/passwd && diff /cygdrive/c/chef/cache/group /etc/group "
#    cwd 'c:\cygwin\bin' 
#    environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
#    command <<-EOS
#    cygrunsrv --stop sshd 
#    cygrunsrv --start sshd
#    EOS
#end
##
# delete our files
# file passwd/group do
#   action :delete
#   end
#/giant FIXME


# Start Hack zone
#
# restart cygwin's sshd if either of group or passwd has changed since last run
#
# I'm probably doing this the wrong way, but I just can't figure how to properly do a restart
# of the service...  Can't send 2 lines command to the dos prompt, can't call diff correctly
# as a only_if conditions, ....
#
# So since I need this NOW, I'm going to regenerate the passwd/group file and restart the sshd service
# on every run.... :(
#
%w(passwd group).each do |what| 
    execute "mk#{what}-tmp" do
        cwd 'c:\cygwin\bin' # Get bash in our path!
        environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
        command "bash -c \"/usr/bin/mk#{what} -l > /etc/#{what}  \" "
    end
end

%w(stop start).each do |op|
    execute "cygrunsrv-#{op}" do
        #    only_if "bash -c \"/usr/bin/diff #{node['cygwin']['cygdrive_cache_path']}/passwd /etc/passwd \" ",
        #        :environment => {'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'}, :cwd => 'c:\cygwin\bin' 

        #&& diff #{node['cygwin']['cygdrive_cache_path']}/group /etc/group"
        #only_if "bash "diff /cygdrive/c/chef/cache/passwd /etc/passwd && diff /cygdrive/c/chef/cache/group /etc/group "
        cwd 'c:\cygwin\bin' 
        environment ({'PATH' => '$PATH:.:/cygdrive/c/cygwin/bin'})
        command "cygrunsrv --#{op} sshd "
    end
end



