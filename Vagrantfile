require 'rbconfig'
is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
  if is_windows
    config.vm.synced_folder ".", "/lara", type: "smb"
  else
    config.vm.synced_folder ".", "/lara", type: "rsync", rsync__exclude: [".git/", "log", "tmp"]
  end
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :docker
  # config.vm.provision :docker_compose, run: "always"
  # To rebuild the containers each time:
  config.vm.provision :docker_compose, rebuild: true, run: "always"
end
