
define :cygwin_package, :action => "install" do

  ## FIXME: add support for uninstall, upgrades, etc.

  if node['cygwin']['proxy'].nil?
    proxycmd  = ""
  else
    proxycmd  = "--proxy #{node['cygwin']['proxy']}"
  end
  execute "setup-cygwin-packages.exe" do
    # FIXME: how do we do this idempotently?
    #not_if {File.exists?("/etc/passwd")}
    not_if {
      `cygcheck -c #{params[:name]}`.include? "OK"
    }
    cwd node['cygwin']['download_path'] 
    command "setup.exe -q -O -R #{node['cygwin']['home']} -s #{node['cygwin']['site']} #{proxycmd} -P #{params[:name]}"
    action :run
  end
end
