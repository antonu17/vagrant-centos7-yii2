# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.synced_folder "home", "/var/www"
  config.vm.synced_folder "src", "/var/www/farm-market"
  config.vm.synced_folder "comet", "/var/www/node"
  config.vm.hostname = "torbor.dev"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.aliases = %w(admin.torbor.dev)

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "2048",
    ]
  end

  config.vm.provision :hostmanager

  config.vm.provision :puppet do |puppet|
    puppet.options = "--verbose"
    puppet.environment = "test"
    puppet.environment_path = "puppet/env"
    puppet_manifest_file = "site.pp"
    puppet.module_path = "puppet/modules"
  end

end
