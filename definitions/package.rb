
define :cygwin_package, :action => "install" do

  ## FIXME: add support for uninstall, upgrades, etc.

# FIXME: we should ditch this parameter and just use Chef's
  if Chef::Config.has_key? :http_proxy
    proxycmd  = "--proxy #{node['cygwin']['proxy']}"
  else
    proxycmd  = ""
  end

  log("Looking at cygwin package #{params[:name]}")

  execute "setup-cygwin-packages.exe" do
    # FIXME: how do we do this idempotently?
    #not_if {File.exists?("/etc/passwd")}
    not_if {
      `#{node['cygwin']['home']}/bin/cygcheck -c #{params[:name]}`.include? "OK"
    }
    cwd node['cygwin']['download_path'] 
    command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd} -P #{params[:name]}"
    action :run
  end
end
