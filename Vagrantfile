# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  
  # IP estática
  config.vm.network "private_network", ip: "192.168.56.8"
  
  # Redirigimos el puerto 3000 (Node) para ver la web desde tu navegador
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # Aprovisionamiento
  config.vm.provision :shell, path: "bootstrap.sh"
end