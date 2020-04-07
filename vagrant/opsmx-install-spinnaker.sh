#!/bin/bash
#
#VARIABLE
export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

#Create SWAP File
sudo fallocate -l 4G /swapfile #This will create 4GB swapfile
sudo chmod 600 /swapfile #Changing the Permission
sudo mkswap /swapfile #formatting the swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab #Adding entry in fstab
sudo swapon /swapfile #To enable the Swap

SPINNAKER_VERSION=1.19.4 #Spinnaker version
curl -Os https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user vagrant -y
. /home/vagrant/.bashrc
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker vagrant
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -v /mnt/data:/data \
  minio/minio server /data

sudo apt-get -y install jq

MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint http://127.0.0.1:9090 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key

hal config storage edit --type s3

# env flag that need to be set:


set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi
mkdir -p /home/vagrant/.hal/default/service-settings/
touch /home/vagrant/.hal/default/service-settings/gate.yml
touch /home/vagrant/.hal/default/service-settings/deck.yml
sudo hal config version edit --version $SPINNAKER_VERSION
sudo echo "host: 0.0.0.0" |sudo tee \
    /home/vagrant/.hal/default/service-settings/gate.yml \
    /home/vagrant/.hal/default/service-settings/deck.yml
sudo hal config security ui edit --override-base-url http://192.168.33.10:9000 
sudo hal config security api edit --override-base-url http://192.168.33.10:8084
sudo hal deploy apply
sudo systemctl daemon-reload
sudo hal deploy connect
sleep 10
sudo systemctl enable redis-server.service
sudo systemctl start redis-server.service
printf " -------------------------------------------------------------- \n|     Connect here to spinnaker: http://192.168.33.10:9000/    |\n --------------------------------------------------------------"

