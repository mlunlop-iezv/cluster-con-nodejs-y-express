# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"

#Le ponemos la ip que sea estatica
  config.vm.network "private_network", ip: "192.168.56.8" 

#Vinculamos la maquina virtual con el bootstrap.sh
  config.vm.provision :shell, path: "bootstrap.sh"
  end