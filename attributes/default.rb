
default['cygwin']['download_path'] = "c:/chef/downloads"


# URL from where to download
default['cygwin']['download_url'] = "http://cygwin.com/setup.exe"



# Cygwin HOME
default['cygwin']['home'] = "c:/cygwin"
# cygwin download site
default['cygwin']['site'] = "http://mirrors.kernel.org/sourceware/cygwin/"
# proxy to use for cygwin setup.exe
# hostname:port (no http://)
default['cygwin']['proxy'] =  nil



default['cygwin']['sshd_user']   =  'cyg_server'
default['cygwin']['sshd_passwd'] = nil 

