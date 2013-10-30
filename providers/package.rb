def initialize(*args)
  super
  @action = :install
end

action :install do

  if Chef::Config['http_proxy'].nil?
    proxycmd  = ""
  else
    proxycmd  = "--proxy #{Chef::Config['http_proxy']}"
  end

  log("Cygwin package: #{new_resource.name}")

  execute "install Cygwin package: #{new_resource.name}" do
    cwd node['cygwin']['download_path']
    command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd} -P #{new_resource.name}"
    not_if "#{node['cygwin']['home']}/bin/cygcheck -c #{new_resource.name}".include? "OK"
  end

  new_resource.updated_by_last_action(true)
end
