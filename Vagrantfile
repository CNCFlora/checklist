# -*- mode: ruby -*-
# vi: set ft=ruby

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end

    config.vm.network "private_network", ip: "192.168.50.16"
    config.vm.network :forwarded_port, host: 9292, guest: 9292, auto_correct: true
    

    config.vm.provision "docker" do |d|
        d.run "coreos/etcd", name:"etcd" , args: "-p 8001:80 -p 4001:4001 "
        d.run "cncflora/connect", name: "connect", args: "-P -v /var/connect:/var/floraconnect:rw"
        d.run "cncflora/datahub", name: "datahub", args: "-P -v /var/couchdb:/var/lib/couchdb:rw"
    end

    config.vm.provision :shell, :path => "bootstrap.sh"

end
