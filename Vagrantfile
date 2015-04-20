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
        d.run "cncflora/connect", name: "connect", args: "-p 8080:80 -v /var/connect:/var/floraconnect:rw"
        d.run "cncflora/elasticsearch", name: "elasticsearch", args: "-p 9200:9200"
        d.run "cncflora/couchdb", name: "couchdb", args: "-p 5984:5984 -p 9001:9001 --link elasticsearch:elasticsearch -v /var/couchdb:/var/lib/couchdb:rw"
        d.run "cncflora/floradata", name:"floradata", args: "-p 8181:80"
    end

    config.vm.provision :shell, :path => "vagrant.sh"
end
