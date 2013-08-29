
default['cygwin']['download_path'] = "c:/chef/downloads"

# Set this to the cygdrive value of Chef::Config[:file_cache_path]
default['cygwin']['cygdrive_cache_path'] = "/cygdrive/c/chef/cache"


# URL from where to download
default['cygwin']['64bit'] = false
default['cygwin']['download_url'] = "http://cygwin.com/setup-x86#{ node['cygwin']['64bit'] ? "_64": ""}.exe"


# Cygwin HOME
default['cygwin']['home'] = "c:/cygwin"
# cygwin download site
default['cygwin']['site'] = "http://mirrors.kernel.org/sourceware/cygwin/"
# proxy to use for cygwin setup.exe
# hostname:port (no http://)
default['cygwin']['proxy'] =  nil



default['cygwin']['sshd_user']   =  'cyg_server'
default['cygwin']['sshd_passwd'] = nil 



