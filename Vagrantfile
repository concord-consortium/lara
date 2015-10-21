Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude:
    [".git/", "log", "tmp"]
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :docker
  config.vm.provision :docker_compose, run: "always"
  # To rebuild the containers each time:
  # config.vm.provision :docker_compose, yml: "/vagrant/docker-compose.yml", rebuild: true, run: "always"
end
