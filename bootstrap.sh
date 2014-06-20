#!/usr/bin/env bash

add-apt-repository  ppa:brightbox/ruby-ng -y
apt-get update
apt-get upgrade -y
#sudo apt-get install -y docker.io
#sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
#sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
sudo apt-get install git curl wget ruby2.1 ruby2.1-dev -y


if [[ ! -e /home/vagrant/.app_done ]] ; then
    # config ruby gems to use https
    gem sources -r http://rubygems.org/
    gem sources -a https://rubygems.org/

    gem install bundler
    gem install couchdb_basic

    su vagrant -lc 'cd /vagrant && [[ ! -e config.yml ]] && touch config.yml'
    su vagrant -lc 'touch /home/vagrant/.app_done'
fi

# docker register to etcd
if [[ ! -e /usr/bin/docker2etcd ]]; then
    wget https://gist.githubusercontent.com/diogok/9604900/raw/afcc71dbec207a4f7b12a98e695622d902b5b022/register-docker-to-etcd.sh \
        -O /usr/bin/docker2etcd
    chmod +x /usr/bin/docker2etcd
fi
/usr/bin/docker2etcd

# setup couchdb
HUB=$(docker ps | grep couchdb | awk '{ print $10 }' | grep -e '[0-9]\{5\}' -o)
#HUB=$(docker ps | grep datahub | awk '{ print $10 }' | grep -e '[0-9]\{5\}' -o)
curl -X PUT http://localhost:$HUB/lista_flora


