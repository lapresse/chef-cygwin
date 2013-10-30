hosts_defs = {
  "win2k8r2-64bit-chef11" => {
    "hostname" => "win2k8r2-64bit-chef11",
    "ipaddress" => "10.11.12.18",
    "environment" => "production",
    "run_list" => [
      "recipe[cygwin::ssh]"
    ]
  },
  "win2k8r2-64bit-chef10" => {
    "hostname" => "win2k8r2-64bit-chef10",
    "ipaddress" => "10.11.12.19",
    "environment" => "qidc",
    "run_list" => [
      "recipe[cygwin::ssh]"
    ]
  }
}

Vagrant.configure("2") do |global_config|
  hosts_defs.each_pair do |name, options|
    global_config.vm.define name do |config|
      config.vm.box = name
      config.vm.box_url = "http://gustavo.lapresse.ca/vagrant/boxes/#{name}.box"
      config.vm.hostname = "cygwin-#{options['hostname']}"
      config.vm.network :private_network, ip: options["ipaddress"]

      # Windows
      if name =~ /win2k8/
        config.windows.halt_timeout = 25
        config.winrm.username = "vagrant"
        config.winrm.password = "vagrant"
        config.vm.guest = :windows
        case name
          when 'win2k8r2-64bit-chef11'
            config.vm.network :forwarded_port, guest: 3389, host: 3389
            config.vm.network :forwarded_port, guest: 5985, host: 5985
          when 'win2k8r2-64bit-chef10'
            config.vm.network :forwarded_port, guest: 3389, host: 33389
            config.vm.network :forwarded_port, guest: 5985, host: 55985
        end
      end

      config.vm.provision :chef_solo do |chef|
        chef.run_list = options['run_list']
        chef.json = {
          "cygwin" => {
            "sshd_passwd" => "vagrant"
          }
        }
      end
    end
  end
end
