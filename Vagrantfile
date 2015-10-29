require 'rbconfig'
is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  if is_windows
    config.vm.synced_folder ".", "/lara", type: "smb"
  else
    config.vm.synced_folder ".", "/lara", type: "rsync", rsync__exclude: [".git/", "log", "tmp"]
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.box = "ubuntu/trusty64"

  config.vm.define 'default' do |node|

    config.vm.provision :docker
    # config.vm.provision :docker_compose, run: "always"
    # To rebuild the containers each time:
    config.vm.provision :docker_compose, rebuild: true, run: "always"

    config.vm.network "private_network", ip: "10.10.10.10"
    config.vm.hostname = 'lara'
    config.hostmanager.aliases = %w(hello.lara app.lara web.lara authoring.lara)
  end
end
