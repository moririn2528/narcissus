#!/bin/bash
echo "install"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu `lsb_release -cs` test"
sudo apt update
sudo apt install -y docker-ce

sudo gpasswd -a $(whoami) docker
sudo chgrp docker /var/run/docker.sock
sudo service docker restart

mkdir -p narcissus/docker/cloud/log
mkdir -p narcissus/docker/local/log
touch narcissus/docker/cloud/log/go.log
touch narcissus/docker/local/log/go.log
